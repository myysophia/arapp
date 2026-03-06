import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        FeatureScaffoldView(
            title: "登录",
            subtitle: "匿名先用，登录可选。Google / GitHub / Apple 按钮后续在这里接入。",
            primaryActionTitle: "返回主流程",
            primaryAction: {
                appState.route = nil
            }
        )
    }
}
