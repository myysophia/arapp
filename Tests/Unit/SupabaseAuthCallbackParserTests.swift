import XCTest
@testable import ArApp

final class SupabaseAuthCallbackParserTests: XCTestCase {
    private let parser = SupabaseAuthCallbackParser()

    func testParseAcceptsAuthorizationCodeFromQuery() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "arapp://auth/callback?code=abc123"))

        let payload = try parser.parse(url: url, configuration: configuration)

        XCTAssertEqual(payload.outcome, .authorizationCode("abc123"))
    }

    func testParseAcceptsAuthorizationCodeFromFragment() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "arapp://auth/callback#code=from_fragment"))

        let payload = try parser.parse(url: url, configuration: configuration)

        XCTAssertEqual(payload.outcome, .authorizationCode("from_fragment"))
    }

    func testParseMapsAccessDeniedToCancelled() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "arapp://auth/callback?error=access_denied&error_description=user_cancelled"))

        let payload = try parser.parse(url: url, configuration: configuration)

        XCTAssertEqual(payload.outcome, .cancelled)
    }

    func testParseKeepsProviderErrorDetails() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "arapp://auth/callback?error=server_error&error_description=provider_down"))

        let payload = try parser.parse(url: url, configuration: configuration)

        XCTAssertEqual(
            payload.outcome,
            .providerFailure(code: "server_error", description: "provider_down")
        )
    }

    func testParseRejectsMismatchedCallbackURL() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "wrong://auth/callback?code=abc123"))

        XCTAssertThrowsError(try parser.parse(url: url, configuration: configuration)) { error in
            guard case AuthServiceError.invalidCallback = error else {
                return XCTFail("期望 invalidCallback，实际为 \(error)")
            }
        }
    }

    func testParseRejectsMissingCodeAndError() throws {
        let configuration = makeConfiguration()
        let url = try XCTUnwrap(URL(string: "arapp://auth/callback?state=only"))

        XCTAssertThrowsError(try parser.parse(url: url, configuration: configuration)) { error in
            guard case AuthServiceError.invalidCallback = error else {
                return XCTFail("期望 invalidCallback，实际为 \(error)")
            }
        }
    }

    private func makeConfiguration() -> SupabaseAuthConfiguration {
        SupabaseAuthConfiguration(
            projectURL: URL(string: "https://example.supabase.co")!,
            anonKey: "anon-key",
            redirectScheme: "arapp",
            redirectHost: "auth",
            redirectPath: "/callback"
        )
    }
}
