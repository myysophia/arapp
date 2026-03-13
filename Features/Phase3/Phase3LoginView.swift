import SwiftUI

struct Phase3LoginView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(store.loginModel.title)
                        .font(AppTypography.titleHero)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(store.loginModel.subtitle)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(AppSpacing.lg)
                .appCardSurface()

                if store.loginState == .failed {
                    StateView(
                        type: .error,
                        title: "Login issue",
                        bodyText: store.loginModel.errorMessage,
                        ctaTitle: "清除",
                        onTapCTA: store.dismissLoginError
                    )
                }

                VStack(spacing: AppSpacing.sm) {
                    providerButton(
                        provider: .google,
                        title: "Continue with Google",
                        subtitle: "用于同步与跨设备恢复",
                        icon: "globe",
                        isLoading: store.loginState == .loadingGoogle
                    )
                    providerButton(
                        provider: .github,
                        title: "Continue with GitHub",
                        subtitle: "用于开发者账号与历史恢复",
                        icon: "chevron.left.forwardslash.chevron.right",
                        isLoading: store.loginState == .loadingGitHub,
                        background: AppColor.textPrimary,
                        foreground: .white,
                        border: false
                    )
                    providerButton(
                        provider: .apple,
                        title: "Continue with Apple",
                        subtitle: "保持轻干预，不放大登录压力",
                        icon: "apple.logo",
                        isLoading: store.loginState == .loadingApple,
                        background: .black,
                        foreground: .white,
                        border: false
                    )
                }
                .padding(AppSpacing.lg)
                .appCardSurface()

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(store.loginModel.anonymousTitle)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(store.loginModel.anonymousSubtitle)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)

                    Button("Continue without login") {
                        store.continueWithoutLogin()
                    }
                    .buttonStyle(.plain)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.brandDeep)
                }
                .padding(AppSpacing.lg)
                .appCardSurface()

                Button("触发登录失败态") {
                    store.failLogin()
                }
                .buttonStyle(.plain)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .appPageBackground()
    }

    private func providerButton(
        provider: AuthProvider,
        title: String,
        subtitle: String,
        icon: String,
        isLoading: Bool,
        background: Color = AppColor.surface,
        foreground: Color = AppColor.textPrimary,
        border: Bool = true
    ) -> some View {
        AuthProviderButton(
            title: isLoading ? "Connecting..." : title,
            subtitle: subtitle,
            icon: icon,
            backgroundColor: background,
            foregroundColor: foreground,
            showsBorder: border
        ) {
            store.completeLogin(with: provider)
        }
    }
}
