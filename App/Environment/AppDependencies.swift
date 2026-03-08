import Foundation

struct AppDependencies: Sendable {
    let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    @MainActor
    func makeTodayScreenModel() -> TodayScreenModel {
        TodayScreenModel(environment: environment)
    }

    @MainActor
    func makeMapScreenModel() -> MapScreenModel {
        MapScreenModel(environment: environment)
    }

    @MainActor
    func makeAlertsScreenModel() -> AlertsScreenModel {
        AlertsScreenModel(environment: environment)
    }

    @MainActor
    func makeAuthFlowModel() -> AuthFlowModel {
        AuthFlowModel(service: makeAuthService())
    }

    private func makeAuthService() -> any AuthServicing {
        guard
            environment.prefersLiveServices,
            let supabase = environment.supabase
        else {
            return MockAuthService.anonymous
        }

        return SupabaseAuthService(
            configuration: SupabaseAuthConfiguration(
                projectURL: supabase.projectURL,
                anonKey: supabase.anonKey,
                redirectScheme: supabase.redirectScheme,
                redirectHost: supabase.redirectHost,
                redirectPath: supabase.redirectPath
            )
        )
    }
}
