import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            TabView(selection: selectedTabBinding) {
                TodayView()
                    .tabItem {
                        Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
                    }
                    .tag(AppTab.today)

                MapView()
                    .tabItem {
                        Label(AppTab.map.title, systemImage: AppTab.map.systemImage)
                    }
                    .tag(AppTab.map)

                AlertsView()
                    .tabItem {
                        Label(AppTab.alerts.title, systemImage: AppTab.alerts.systemImage)
                    }
                    .tag(AppTab.alerts)

                ProfileView()
                    .tabItem {
                        Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
                    }
                    .tag(AppTab.profile)
            }
            .navigationDestination(item: routeBinding) { route in
                switch route {
                case .login:
                    LoginView()
                case .onboarding:
                    OnboardingFlowView()
                }
            }
            .task {
                if !appState.hasSeenOnboarding {
                    appState.route = .onboarding
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
