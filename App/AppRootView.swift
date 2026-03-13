import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            TabView(selection: selectedTabBinding) {
                TodayView(screenModel: appState.todayScreenModel)
                    .tabItem {
                        Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
                    }
                    .tag(AppTab.today)

                MapView(screenModel: appState.mapScreenModel)
                    .tabItem {
                        Label(AppTab.map.title, systemImage: AppTab.map.systemImage)
                    }
                    .tag(AppTab.map)

                AlertsView(screenModel: appState.alertsScreenModel)
                    .tabItem {
                        Label(AppTab.alerts.title, systemImage: AppTab.alerts.systemImage)
                    }
                    .tag(AppTab.alerts)

                ProfileView(authFlow: appState.authFlowModel)
                    .tabItem {
                        Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
                    }
                    .tag(AppTab.profile)
            }
            .navigationDestination(item: routeBinding) { route in
                switch route {
                case .login:
                    LoginView(authFlow: appState.authFlowModel)
                case .onboarding:
                    OnboardingFlowView()
                case .statesCatalog:
                    StatesCatalogView()
                }
            }
            .task {
                if !appState.hasSeenOnboarding {
                    appState.route = .onboarding
                }
            }
        }
        .environment(\.locale, Locale(identifier: appState.localeIdentifier))
        .onOpenURL { url in
            Task {
                let handled = await appState.authFlowModel.handleOAuthCallback(url)
                guard handled else { return }

                if !appState.authFlowModel.isAnonymous {
                    appState.selectedTab = .profile
                    appState.route = nil
                }
            }
        }
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )
    }

    private var routeBinding: Binding<AppRoute?> {
        Binding(
            get: { appState.route },
            set: { appState.route = $0 }
        )
    }
}
