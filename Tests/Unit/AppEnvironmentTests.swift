import XCTest
@testable import ArApp

final class AppEnvironmentTests: XCTestCase {
    func testResolveUsesMockByDefault() {
        let environment = AppEnvironment.resolve(
            processEnv: [:],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.runtimeMode, .mock)
        XCTAssertFalse(environment.prefersLiveServices)
        XCTAssertNil(environment.edgeBaseURL)
        XCTAssertEqual(environment.edgeTimeoutSeconds, AppEnvironmentDefaults.edgeTimeoutSeconds)
        XCTAssertNil(environment.edgeRuntime)
        XCTAssertNil(environment.supabase)
    }

    func testResolveMapsRealAliasToLiveMode() {
        let environment = AppEnvironment.resolve(
            processEnv: ["ARAPP_RUNTIME_MODE": "real"],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.runtimeMode, .staging)
        XCTAssertTrue(environment.prefersLiveServices)
    }

    func testResolvePrefersProcessEnvironmentOverInfoDictionary() {
        let environment = AppEnvironment.resolve(
            processEnv: ["ARAPP_RUNTIME_MODE": "production"],
            infoDictionary: ["ARAPP_RUNTIME_MODE": "mock"]
        )

        XCTAssertEqual(environment.runtimeMode, .production)
    }

    func testResolveParsesEdgeTimeoutSeconds() {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_EDGE_BASE_URL": "https://example.functions.supabase.co",
                "ARAPP_EDGE_TIMEOUT_SECONDS": "30"
            ],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.edgeTimeoutSeconds, 30)
        XCTAssertEqual(environment.edgeRuntime?.timeoutInterval, 30)
    }

    func testResolveFallsBackToDefaultTimeoutWhenInvalid() {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_EDGE_BASE_URL": "https://example.functions.supabase.co",
                "ARAPP_EDGE_TIMEOUT_SECONDS": "0"
            ],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.edgeTimeoutSeconds, AppEnvironmentDefaults.edgeTimeoutSeconds)
    }

    func testResolveBuildsSupabaseConfigOnlyWhenAllFieldsPresent() {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_SUPABASE_URL": "https://example.supabase.co",
                "ARAPP_SUPABASE_ANON_KEY": "anon-key",
                "ARAPP_SUPABASE_REDIRECT_SCHEME": "arapp",
                "ARAPP_SUPABASE_REDIRECT_HOST": "auth",
                "ARAPP_SUPABASE_REDIRECT_PATH": "/callback"
            ],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.supabase?.projectURL.absoluteString, "https://example.supabase.co")
        XCTAssertEqual(environment.supabase?.anonKey, "anon-key")
        XCTAssertEqual(environment.supabase?.redirectScheme, "arapp")
        XCTAssertEqual(environment.supabase?.redirectHost, "auth")
        XCTAssertEqual(environment.supabase?.redirectPath, "/callback")
    }

    func testResolveSupabaseCallbackUsesDefaultsWhenHostOrPathMissing() {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_SUPABASE_URL": "https://example.supabase.co",
                "ARAPP_SUPABASE_ANON_KEY": "anon-key",
                "ARAPP_SUPABASE_REDIRECT_SCHEME": "arapp"
            ],
            infoDictionary: [:]
        )

        XCTAssertEqual(environment.supabase?.redirectHost, "auth")
        XCTAssertEqual(environment.supabase?.redirectPath, "/callback")
    }

    func testResolveSkipsSupabaseConfigWhenFieldsMissing() {
        let environment = AppEnvironment.resolve(
            processEnv: [
                "ARAPP_SUPABASE_URL": "https://example.supabase.co",
                "ARAPP_SUPABASE_ANON_KEY": "anon-key"
            ],
            infoDictionary: [:]
        )

        XCTAssertNil(environment.supabase)
    }
}
