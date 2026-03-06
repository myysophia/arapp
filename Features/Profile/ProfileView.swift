import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        FeatureScaffoldView(
            title: "我的",
            subtitle: "账户、语言、单位和隐私设置会在这里承接。",
            primaryActionTitle: "打开登录页",
            primaryAction: {
                appState.route = .login
            }
        )
    }
}
