import Foundation

struct AppDependencies: Sendable {
    let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    @MainActor
    func makeTodayScreenModel() -> TodayScreenModel {
        let appEnvironment = self.environment
        return TodayScreenModel(
            environment: appEnvironment,
            liveClientFactory: {
                try LivePollenClientFactory(environment: appEnvironment).makeClient()
            }
        )
    }

    @MainActor
    func makeMapScreenModel() -> MapScreenModel {
        let appEnvironment = self.environment
        return MapScreenModel(
            environment: appEnvironment,
            liveClientFactory: {
                try LivePollenClientFactory(environment: appEnvironment).makeClient()
            }
        )
    }

    @MainActor
    func makeAlertsScreenModel() -> AlertsScreenModel {
        let appEnvironment = self.environment
        return AlertsScreenModel(
            environment: appEnvironment,
            liveClientFactory: {
                try LivePollenClientFactory(environment: appEnvironment).makeClient()
            }
        )
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
