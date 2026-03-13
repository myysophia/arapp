import SwiftUI

struct Phase3DebugPanelView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        NavigationStack {
            List {
                Section("App Flow") {
                    Picker("Flow", selection: $store.flowState) {
                        Text("Onboarding").tag(Phase3FlowState.onboarding)
                        Text("Login").tag(Phase3FlowState.login)
                        Text("Main").tag(Phase3FlowState.main)
                    }

                    Picker("Selected Tab", selection: $store.selectedTab) {
                        ForEach(AppTab.allCases) { tab in
                            Text(tab.title).tag(tab)
                        }
                    }
                }

                Section("Screen States") {
                    Picker("Onboarding", selection: $store.onboardingState) {
                        Text("Baseline").tag(Phase3OnboardingState.baseline)
                        Text("Location denied").tag(Phase3OnboardingState.locationDenied)
                        Text("Notification skipped").tag(Phase3OnboardingState.notificationSkipped)
                    }

                    Picker("Login", selection: $store.loginState) {
                        Text("Idle").tag(Phase3LoginState.idle)
                        Text("Google loading").tag(Phase3LoginState.loadingGoogle)
                        Text("GitHub loading").tag(Phase3LoginState.loadingGitHub)
                        Text("Apple loading").tag(Phase3LoginState.loadingApple)
                        Text("Failed").tag(Phase3LoginState.failed)
                    }

                    Picker("Today", selection: $store.todayState) {
                        Text("Loading").tag(Phase3TodayState.loading)
                        Text("Success").tag(Phase3TodayState.success)
                        Text("Stale").tag(Phase3TodayState.stale)
                        Text("Error").tag(Phase3TodayState.error)
                        Text("Empty").tag(Phase3TodayState.empty)
                        Text("Offline").tag(Phase3TodayState.offline)
                    }

                    Picker("Map", selection: $store.mapState) {
                        Text("Coverage").tag(Phase3MapState.coverage)
                        Text("Selected").tag(Phase3MapState.selected)
                        Text("Search Sheet").tag(Phase3MapState.searchSheet)
                        Text("Source Sheet").tag(Phase3MapState.sourceSheet)
                        Text("No Location").tag(Phase3MapState.noLocation)
                        Text("Offline").tag(Phase3MapState.offline)
                    }

                    Picker("Alerts", selection: $store.alertsState) {
                        Text("Saved").tag(Phase3AlertsState.saved)
                        Text("Anonymous").tag(Phase3AlertsState.anonymous)
                        Text("Notifications Off").tag(Phase3AlertsState.notificationsOff)
                        Text("Empty").tag(Phase3AlertsState.empty)
                        Text("Error").tag(Phase3AlertsState.error)
                    }

                    Picker("Profile", selection: $store.profileState) {
                        Text("Anonymous").tag(Phase3ProfileState.anonymous)
                        Text("Signed In").tag(Phase3ProfileState.signedIn)
                        Text("Delete Confirm").tag(Phase3ProfileState.deleteConfirm)
                    }
                }

                Section("Review") {
                    NavigationLink("Open States & Overlays Catalog") {
                        StatesCatalogView()
                    }
                }
            }
            .navigationTitle("Phase 3 Debug")
        }
    }
}
