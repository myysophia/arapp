import Foundation

enum BuildConfiguration: String, Sendable {
    case debug
    case release
    case unknown

    static func resolve(from rawValue: String?) -> BuildConfiguration {
        guard let rawValue else { return .unknown }
        switch rawValue.lowercased() {
        case "debug":
            return .debug
        case "release":
            return .release
        default:
            return .unknown
        }
    }
}

enum AppRuntimeMode: String, CaseIterable, Sendable {
    case mock
    case staging
    case production

    static func resolve(from rawValue: String?) -> AppRuntimeMode {
        guard let rawValue else { return .mock }

        switch rawValue.lowercased() {
        case "mock":
            return .mock
        case "staging", "stage", "client", "real", "live":
            return .staging
        case "production", "prod":
            return .production
        default:
            return .mock
        }
    }

    var prefersLiveServices: Bool {
        switch self {
        case .mock:
            return false
        case .staging, .production:
            return true
        }
    }
}

struct SupabaseRuntimeConfiguration: Sendable, Equatable {
    let projectURL: URL
    let anonKey: String
    let redirectScheme: String
    let redirectHost: String
    let redirectPath: String
}

struct AppEnvironment: Sendable, Equatable {
    let buildConfiguration: BuildConfiguration
    let runtimeMode: AppRuntimeMode
    let edgeBaseURL: URL?
    let accessToken: String?
    let supabase: SupabaseRuntimeConfiguration?

    static var current: AppEnvironment {
        resolve(
            processEnv: ProcessInfo.processInfo.environment,
            infoDictionary: Bundle.main.infoDictionary ?? [:]
        )
    }

    var prefersLiveServices: Bool {
        runtimeMode.prefersLiveServices
    }

    static func resolve(
        processEnv: [String: String],
        infoDictionary: [String: Any]
    ) -> AppEnvironment {
        let runtimeMode = AppRuntimeMode.resolve(from: value(for: AppEnvironmentKey.runtimeMode, processEnv: processEnv, infoDictionary: infoDictionary))
        let edgeBaseURL = makeURL(value(for: AppEnvironmentKey.edgeBaseURL, processEnv: processEnv, infoDictionary: infoDictionary))
        let accessToken = value(for: AppEnvironmentKey.accessToken, processEnv: processEnv, infoDictionary: infoDictionary)

        let supabaseURLValue = value(for: AppEnvironmentKey.supabaseURL, processEnv: processEnv, infoDictionary: infoDictionary)
        let supabaseAnonKey = value(for: AppEnvironmentKey.supabaseAnonKey, processEnv: processEnv, infoDictionary: infoDictionary)
        let supabaseRedirectScheme = value(for: AppEnvironmentKey.supabaseRedirectScheme, processEnv: processEnv, infoDictionary: infoDictionary)
        let supabaseRedirectHost = value(for: AppEnvironmentKey.supabaseRedirectHost, processEnv: processEnv, infoDictionary: infoDictionary)
        let supabaseRedirectPath = value(for: AppEnvironmentKey.supabaseRedirectPath, processEnv: processEnv, infoDictionary: infoDictionary)
        let supabase = makeSupabaseConfiguration(
            rawURL: supabaseURLValue,
            anonKey: supabaseAnonKey,
            redirectScheme: supabaseRedirectScheme,
            redirectHost: supabaseRedirectHost,
            redirectPath: supabaseRedirectPath
        )

        return AppEnvironment(
            buildConfiguration: BuildConfiguration.resolve(from: processEnv["CONFIGURATION"]),
            runtimeMode: runtimeMode,
            edgeBaseURL: edgeBaseURL,
            accessToken: accessToken,
            supabase: supabase
        )
    }

    private static func value(
        for key: String,
        processEnv: [String: String],
        infoDictionary: [String: Any]
    ) -> String? {
        if let processValue = normalized(processEnv[key]) {
            return processValue
        }

        if let infoValue = infoDictionary[key] as? String {
            return normalized(infoValue)
        }

        return nil
    }

    private static func normalized(_ rawValue: String?) -> String? {
        guard let rawValue else { return nil }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func makeURL(_ rawValue: String?) -> URL? {
        guard let rawValue else { return nil }
        return URL(string: rawValue)
    }

    private static func makeSupabaseConfiguration(
        rawURL: String?,
        anonKey: String?,
        redirectScheme: String?,
        redirectHost: String?,
        redirectPath: String?
    ) -> SupabaseRuntimeConfiguration? {
        guard
            let rawURL,
            let projectURL = URL(string: rawURL),
            let anonKey,
            let redirectScheme
        else {
            return nil
        }

        return SupabaseRuntimeConfiguration(
            projectURL: projectURL,
            anonKey: anonKey,
            redirectScheme: redirectScheme,
            redirectHost: normalizeRedirectHost(redirectHost) ?? "auth",
            redirectPath: normalizeRedirectPath(redirectPath) ?? "/callback"
        )
    }

    private static func normalizeRedirectHost(_ rawHost: String?) -> String? {
        normalized(rawHost)?.lowercased()
    }

    private static func normalizeRedirectPath(_ rawPath: String?) -> String? {
        guard let value = normalized(rawPath) else { return nil }
        if value.hasPrefix("/") {
            return value
        }
        return "/\(value)"
    }
}

enum AppEnvironmentKey {
    static let runtimeMode = "ARAPP_RUNTIME_MODE"
    static let edgeBaseURL = "ARAPP_EDGE_BASE_URL"
    static let accessToken = "ARAPP_ACCESS_TOKEN"
    static let supabaseURL = "ARAPP_SUPABASE_URL"
    static let supabaseAnonKey = "ARAPP_SUPABASE_ANON_KEY"
    static let supabaseRedirectScheme = "ARAPP_SUPABASE_REDIRECT_SCHEME"
    static let supabaseRedirectHost = "ARAPP_SUPABASE_REDIRECT_HOST"
    static let supabaseRedirectPath = "ARAPP_SUPABASE_REDIRECT_PATH"
}
