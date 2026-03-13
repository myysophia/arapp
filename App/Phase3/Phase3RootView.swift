import SwiftUI

struct Phase3RootView: View {
    @StateObject private var store = Phase3DemoStore()

    var body: some View {
        Group {
            switch store.flowState {
            case .onboarding:
                Phase3OnboardingView(store: store)
            case .login:
                Phase3LoginView(store: store)
            case .main:
                Phase3MainTabView(store: store)
            }
        }
    }
}

private struct Phase3MainTabView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                Phase3TodayView(store: store)
                    .navigationTitle("Today")
            }
            .tabItem {
                Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
            }
            .tag(AppTab.today)

            NavigationStack {
                Phase3MapView(store: store)
                    .navigationTitle("Map")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(AppTab.map.title, systemImage: AppTab.map.systemImage)
            }
            .tag(AppTab.map)

            NavigationStack {
                Phase3AlertsView(store: store)
                    .navigationTitle("Alerts")
            }
            .tabItem {
                Label(AppTab.alerts.title, systemImage: AppTab.alerts.systemImage)
            }
            .tag(AppTab.alerts)

            NavigationStack {
                Phase3ProfileView(store: store)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
            }
            .tag(AppTab.profile)
        }
        .sheet(isPresented: $store.isDebugPanelPresented) {
            Phase3DebugPanelView(store: store)
        }
    }
}
