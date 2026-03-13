import Foundation

protocol PollenAPIClienting: Sendable {
    func fetchSummary(_ query: SummaryQuery) async throws -> APIEnvelope<PollenSummary>
    func fetchForecast(_ query: ForecastQuery) async throws -> APIEnvelope<PollenForecast>
    func fetchSourceMeta(lang: String?) async throws -> APIEnvelope<[SourceMeta]>
    func fetchLocationSuggestions(query: String, lang: String?) async throws -> APIEnvelope<[LocationSuggestion]>
    func upsertAlertSubscription(_ request: AlertSubscriptionRequest) async throws -> APIEnvelope<AlertSubscription>
}

struct SummaryQuery: Sendable {
    let lat: Double
    let lng: Double
    let lang: String?
    let unit: UnitSystem?
}

struct ForecastQuery: Sendable {
    let lat: Double
    let lng: Double
    let days: Int
    let lang: String?
    let unit: UnitSystem?
}

struct AlertSubscriptionRequest: Codable, Sendable {
    let userID: UUID?
    let locationID: UUID
    let thresholdLevel: PollenRiskLevel
    let enabled: Bool
    let quietHours: QuietHours

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case locationID = "location_id"
        case thresholdLevel = "threshold_level"
        case enabled
        case quietHours = "quiet_hours"
    }
}

enum APIClientError: Error, LocalizedError, Sendable {
    case invalidBaseURL
    case invalidResponse
    case unexpectedStatus(code: Int, message: String, retryable: Bool)
    case decodingFailed
    case transportFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            "基础地址无效。"
        case .invalidResponse:
            "服务端返回了无法识别的响应。"
        case let .unexpectedStatus(code, message, _):
            "请求失败（\(code)）：\(message)"
        case .decodingFailed:
            "响应解码失败。"
        case let .transportFailed(message):
            "网络请求失败：\(message)"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .invalidBaseURL:
            false
        case .invalidResponse:
            true
        case let .unexpectedStatus(_, _, retryable):
            retryable
        case .decodingFailed:
            false
        case .transportFailed:
            true
        }
    }
}

struct EdgeFunctionsRequestConfiguration: Sendable, Equatable {
    let baseURL: URL
    let accessToken: String?
    let timeoutInterval: TimeInterval
    let defaultHeaders: [String: String]

    init(
        baseURL: URL,
        accessToken: String? = nil,
        timeoutInterval: TimeInterval = 15,
        defaultHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.accessToken = accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
        self.timeoutInterval = timeoutInterval > 0 ? timeoutInterval : 15
        self.defaultHeaders = defaultHeaders
    }
}

enum LivePollenClientFactoryError: Error, LocalizedError, Sendable {
    case missingEdgeRuntimeConfiguration

    var errorDescription: String? {
        switch self {
        case .missingEdgeRuntimeConfiguration:
            "未配置 Edge Functions 基础地址。"
        }
    }
}

struct LivePollenClientFactory: Sendable {
    let environment: AppEnvironment
    let session: URLSession
    let decoder: JSONDecoder
    let defaultHeaders: [String: String]

    init(
        environment: AppEnvironment,
        session: URLSession = .shared,
        decoder: JSONDecoder = .edgeFunctionsDecoder,
        defaultHeaders: [String: String] = ["X-ArApp-Client": "ios"]
    ) {
        self.environment = environment
        self.session = session
        self.decoder = decoder
        self.defaultHeaders = defaultHeaders
    }

    func makeRequestConfiguration() throws -> EdgeFunctionsRequestConfiguration {
        guard let edgeRuntime = environment.edgeRuntime else {
            throw LivePollenClientFactoryError.missingEdgeRuntimeConfiguration
        }

        return EdgeFunctionsRequestConfiguration(
            baseURL: edgeRuntime.baseURL,
            accessToken: edgeRuntime.accessToken,
            timeoutInterval: edgeRuntime.timeoutInterval,
            defaultHeaders: defaultHeaders
        )
    }

    func makeClient() throws -> any PollenAPIClienting {
        EdgeFunctionsPollenAPIClient(
            configuration: try makeRequestConfiguration(),
            session: session,
            decoder: decoder
        )
    }
}

enum APIEndpoint {
    case summary(SummaryQuery)
    case forecast(ForecastQuery)
    case sourceMeta(lang: String?)
    case locationSuggestions(query: String, lang: String?)
    case alertSubscription(AlertSubscriptionRequest)

    var path: String {
        switch self {
        case .summary:
            "/v1/pollen/summary"
        case .forecast:
            "/v1/pollen/forecast"
        case .sourceMeta:
            "/v1/meta/sources"
        case .locationSuggestions:
            "/v1/locations/suggest"
        case .alertSubscription:
            "/v1/alerts/subscriptions"
        }
    }

    var method: String {
        switch self {
        case .alertSubscription:
            "POST"
        default:
            "GET"
        }
    }

    func makeURLRequest(configuration: EdgeFunctionsRequestConfiguration) throws -> URLRequest {
        guard var components = URLComponents(
            url: configuration.baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIClientError.invalidBaseURL
        }

        switch self {
        case let .summary(query):
            components.queryItems = [
                URLQueryItem(name: "lat", value: String(query.lat)),
                URLQueryItem(name: "lng", value: String(query.lng)),
                URLQueryItem(name: "lang", value: query.lang),
                URLQueryItem(name: "unit", value: query.unit?.rawValue)
            ].compactMap { item in
                item.value == nil ? nil : item
            }
        case let .forecast(query):
            components.queryItems = [
                URLQueryItem(name: "lat", value: String(query.lat)),
                URLQueryItem(name: "lng", value: String(query.lng)),
                URLQueryItem(name: "days", value: String(query.days)),
                URLQueryItem(name: "lang", value: query.lang),
                URLQueryItem(name: "unit", value: query.unit?.rawValue)
            ].compactMap { item in
                item.value == nil ? nil : item
            }
        case let .sourceMeta(lang):
            components.queryItems = [URLQueryItem(name: "lang", value: lang)].compactMap { $0.value == nil ? nil : $0 }
        case let .locationSuggestions(query, lang):
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "lang", value: lang)
            ].compactMap { item in
                item.value == nil ? nil : item
            }
        case let .alertSubscription(request):
            components.queryItems = nil
            var urlRequest = try makeBaseRequest(
                components: components,
                configuration: configuration
            )
            urlRequest.httpMethod = method
            urlRequest.httpBody = try JSONEncoder.edgeFunctionsEncoder.encode(request)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return urlRequest
        }

        var request = try makeBaseRequest(
            components: components,
            configuration: configuration
        )
        request.httpMethod = method
        return request
    }

    private func makeBaseRequest(
        components: URLComponents,
        configuration: EdgeFunctionsRequestConfiguration
    ) throws -> URLRequest {
        guard let url = components.url else {
            throw APIClientError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = configuration.timeoutInterval

        for (header, value) in configuration.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken = configuration.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

struct EdgeFunctionsPollenAPIClient: PollenAPIClienting {
    let configuration: EdgeFunctionsRequestConfiguration
    let session: URLSession
    let decoder: JSONDecoder

    init(
        configuration: EdgeFunctionsRequestConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = .edgeFunctionsDecoder
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
    }

    init(
        baseURL: URL,
        accessToken: String? = nil,
        timeoutInterval: TimeInterval = 15,
        session: URLSession = .shared,
        decoder: JSONDecoder = .edgeFunctionsDecoder
    ) {
        self.init(
            configuration: EdgeFunctionsRequestConfiguration(
                baseURL: baseURL,
                accessToken: accessToken,
                timeoutInterval: timeoutInterval
            ),
            session: session,
            decoder: decoder
        )
    }

    func fetchSummary(_ query: SummaryQuery) async throws -> APIEnvelope<PollenSummary> {
        try await send(.summary(query), as: APIEnvelope<PollenSummary>.self)
    }

    func fetchForecast(_ query: ForecastQuery) async throws -> APIEnvelope<PollenForecast> {
        try await send(.forecast(query), as: APIEnvelope<PollenForecast>.self)
    }

    func fetchSourceMeta(lang: String?) async throws -> APIEnvelope<[SourceMeta]> {
        try await send(.sourceMeta(lang: lang), as: APIEnvelope<[SourceMeta]>.self)
    }

    func fetchLocationSuggestions(query: String, lang: String?) async throws -> APIEnvelope<[LocationSuggestion]> {
        try await send(.locationSuggestions(query: query, lang: lang), as: APIEnvelope<[LocationSuggestion]>.self)
    }

    func upsertAlertSubscription(_ request: AlertSubscriptionRequest) async throws -> APIEnvelope<AlertSubscription> {
        try await send(.alertSubscription(request), as: APIEnvelope<AlertSubscription>.self)
    }

    private func send<Response: Decodable & Sendable>(_ endpoint: APIEndpoint, as type: Response.Type) async throws -> Response {
        let request = try endpoint.makeURLRequest(configuration: configuration)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }

            if (200 ... 299).contains(httpResponse.statusCode) {
                do {
                    return try decoder.decode(Response.self, from: data)
                } catch {
                    throw APIClientError.decodingFailed
                }
            }

            let failure = (try? decoder.decode(APIErrorPayload.self, from: data)) ?? APIErrorPayload(code: httpResponse.statusCode, message: "服务端错误", retryable: httpResponse.statusCode >= 500)
            throw APIClientError.unexpectedStatus(code: failure.code, message: failure.message, retryable: failure.retryable)
        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.transportFailed(error.localizedDescription)
        }
    }
}

struct MockPollenAPIClient: PollenAPIClienting {
    var summary: APIEnvelope<PollenSummary>
    var forecast: APIEnvelope<PollenForecast>
    var sourceMeta: APIEnvelope<[SourceMeta]>
    var suggestions: APIEnvelope<[LocationSuggestion]>
    var alertSubscription: APIEnvelope<AlertSubscription>

    static let demo = MockPollenAPIClient(
        summary: APIEnvelope(
            requestID: "mock-summary-001",
            code: 200,
            message: "ok",
            retryable: false,
            payload: PollenSummary(
                id: "summary-shanghai-high",
                cityName: "上海",
                locationID: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00"),
                riskOverall: .high,
                treeLevel: .low,
                grassLevel: .high,
                weedLevel: .high,
                confidence: 0.84,
                updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
                source: .model,
                isStale: false
            )
        ),
        forecast: APIEnvelope(
            requestID: "mock-forecast-001",
            code: 200,
            message: "ok",
            retryable: false,
            payload: PollenForecast(
                days: [
                    ForecastPoint(id: "2026-03-06", date: "2026-03-06", riskOverall: .high, treeLevel: .low, grassLevel: .high, weedLevel: .high),
                    ForecastPoint(id: "2026-03-07", date: "2026-03-07", riskOverall: .veryHigh, treeLevel: .moderate, grassLevel: .veryHigh, weedLevel: .high),
                    ForecastPoint(id: "2026-03-08", date: "2026-03-08", riskOverall: .moderate, treeLevel: .low, grassLevel: .moderate, weedLevel: .low)
                ]
            )
        ),
        sourceMeta: APIEnvelope(
            requestID: "mock-sources-001",
            code: 200,
            message: "ok",
            retryable: false,
            payload: [
                SourceMeta(
                    id: UUID(),
                    providerName: "Primary Model Provider",
                    source: .model,
                    coverageNote: "中国大陆主要城市模型覆盖",
                    licenseNote: "仅用于风险参考，不代表采样监测",
                    active: true,
                    updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
                )
            ]
        ),
        suggestions: APIEnvelope(
            requestID: "mock-locations-001",
            code: 200,
            message: "ok",
            retryable: false,
            payload: [
                LocationSuggestion(id: UUID(), name: "上海", countryCode: "CN", admin1: "上海", lat: 31.2304, lng: 121.4737),
                LocationSuggestion(id: UUID(), name: "杭州", countryCode: "CN", admin1: "浙江", lat: 30.2741, lng: 120.1551)
            ]
        ),
        alertSubscription: APIEnvelope(
            requestID: "mock-alerts-001",
            code: 200,
            message: "ok",
            retryable: false,
            payload: AlertSubscription(
                id: UUID(),
                userID: UUID(),
                locationID: UUID(),
                thresholdLevel: .moderate,
                enabled: true,
                quietHours: QuietHours(enabled: true, start: "22:00", end: "07:00"),
                updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
            )
        )
    )

    func fetchSummary(_ query: SummaryQuery) async throws -> APIEnvelope<PollenSummary> {
        summary
    }

    func fetchForecast(_ query: ForecastQuery) async throws -> APIEnvelope<PollenForecast> {
        forecast
    }

    func fetchSourceMeta(lang: String?) async throws -> APIEnvelope<[SourceMeta]> {
        sourceMeta
    }

    func fetchLocationSuggestions(query: String, lang: String?) async throws -> APIEnvelope<[LocationSuggestion]> {
        suggestions
    }

    func upsertAlertSubscription(_ request: AlertSubscriptionRequest) async throws -> APIEnvelope<AlertSubscription> {
        APIEnvelope(
            requestID: alertSubscription.requestID,
            code: alertSubscription.code,
            message: alertSubscription.message,
            retryable: alertSubscription.retryable,
            payload: AlertSubscription(
                id: alertSubscription.payload.id,
                userID: request.userID,
                locationID: request.locationID,
                thresholdLevel: request.thresholdLevel,
                enabled: request.enabled,
                quietHours: request.quietHours,
                updatedAt: .now
            )
        )
    }
}

private struct APIErrorPayload: Decodable {
    let code: Int
    let message: String
    let retryable: Bool
}

private extension JSONDecoder {
    static let edgeFunctionsDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension JSONEncoder {
    static let edgeFunctionsEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
