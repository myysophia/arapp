import XCTest
@testable import ArApp

final class LivePollenClientFactoryTests: XCTestCase {
    func testMakeRequestConfigurationThrowsWhenEdgeBaseURLMissing() {
        let environment = AppEnvironment.resolve(
            processEnv: [:],
            infoDictionary: [:]
        )
        let factory = LivePollenClientFactory(environment: environment)

        XCTAssertThrowsError(try factory.makeRequestConfiguration()) { error in
            guard case LivePollenClientFactoryError.missingEdgeRuntimeConfiguration = error else {
                return XCTFail("期望 missingEdgeRuntimeConfiguration，实际：\(error)")
            }
        }
    }

    func testMakeRequestConfigurationMapsEnvironmentValues() throws {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_EDGE_BASE_URL": "https://example.functions.supabase.co",
                "ARAPP_ACCESS_TOKEN": "test-token",
                "ARAPP_EDGE_TIMEOUT_SECONDS": "22"
            ],
            infoDictionary: [:]
        )
        let factory = LivePollenClientFactory(environment: environment)

        let configuration = try factory.makeRequestConfiguration()

        XCTAssertEqual(configuration.baseURL.absoluteString, "https://example.functions.supabase.co")
        XCTAssertEqual(configuration.accessToken, "test-token")
        XCTAssertEqual(configuration.timeoutInterval, 22)
        XCTAssertEqual(configuration.defaultHeaders["X-ArApp-Client"], "ios")
    }

    func testMakeClientReturnsEdgeFunctionsClient() throws {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_EDGE_BASE_URL": "https://example.functions.supabase.co"
            ],
            infoDictionary: [:]
        )
        let factory = LivePollenClientFactory(environment: environment)

        let client = try factory.makeClient()

        XCTAssertNotNil(client as? EdgeFunctionsPollenAPIClient)
    }
}
