import XCTest
@testable import ArApp

@MainActor
final class AuthFlowModelTests: XCTestCase {
    func testHandleOAuthCallbackMarksSignedInWhenExchangeSucceeds() async throws {
        let callbackURL = try XCTUnwrap(URL(string: "arapp://auth/callback?code=ok"))
        let service = TestAuthService(
            expectedCallbackURL: callbackURL,
            callbackSession: makeSession(isAnonymous: false, providers: [.google]),
            callbackError: nil
        )
        let model = AuthFlowModel(service: service)

        let handled = await model.handleOAuthCallback(callbackURL)

        XCTAssertTrue(handled)
        XCTAssertFalse(model.isAnonymous)
        XCTAssertEqual(model.phase, .signedIn)
    }

    func testHandleOAuthCallbackIgnoresUnmatchedURL() async throws {
        let expectedURL = try XCTUnwrap(URL(string: "arapp://auth/callback?code=ok"))
        let unrelatedURL = try XCTUnwrap(URL(string: "arapp://other/path?foo=bar"))
        let service = TestAuthService(
            expectedCallbackURL: expectedURL,
            callbackSession: makeSession(isAnonymous: false, providers: [.google]),
            callbackError: nil
        )
        let model = AuthFlowModel(service: service)

        let handled = await model.handleOAuthCallback(unrelatedURL)

        XCTAssertFalse(handled)
        XCTAssertTrue(model.isAnonymous)
        XCTAssertEqual(model.phase, .idle)
        XCTAssertNil(model.errorMessage)
    }

    func testHandleOAuthCallbackShowsErrorWhenExchangeFails() async throws {
        let callbackURL = try XCTUnwrap(URL(string: "arapp://auth/callback?error=access_denied"))
        let service = TestAuthService(
            expectedCallbackURL: callbackURL,
            callbackSession: nil,
            callbackError: .cancelled
        )
        let model = AuthFlowModel(service: service)

        let handled = await model.handleOAuthCallback(callbackURL)

        XCTAssertTrue(handled)
        XCTAssertTrue(model.isAnonymous)
        XCTAssertEqual(model.errorMessage, AuthServiceError.cancelled.localizedDescription)
    }

    private func makeSession(isAnonymous: Bool, providers: [AuthProvider]) -> AuthSession {
        AuthSession(
            userID: isAnonymous ? nil : UUID(),
            providers: providers,
            accessToken: isAnonymous ? nil : "token",
            refreshToken: isAnonymous ? nil : "refresh",
            isAnonymous: isAnonymous
        )
    }
}

private struct TestAuthService: AuthServicing, AuthCallbackSessionExchanging {
    let expectedCallbackURL: URL?
    let callbackSession: AuthSession?
    let callbackError: AuthServiceError?

    func currentSession() async throws -> AuthSession {
        AuthSession(
            userID: nil,
            providers: [],
            accessToken: nil,
            refreshToken: nil,
            isAnonymous: true
        )
    }

    func signIn(with provider: AuthProvider) async throws -> AuthSession {
        AuthSession(
            userID: UUID(),
            providers: [provider],
            accessToken: "token",
            refreshToken: "refresh",
            isAnonymous: false
        )
    }

    func signOut() async throws {
    }

    func exchangeSession(fromCallbackURL url: URL) async throws -> AuthSession {
        if let expectedCallbackURL, expectedCallbackURL != url {
            throw AuthServiceError.invalidCallback
        }

        if let callbackError {
            throw callbackError
        }

        guard let callbackSession else {
            throw AuthServiceError.sessionMissing
        }
        return callbackSession
    }
}
