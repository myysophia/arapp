import SwiftUI

struct Phase3ProfileView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                accountCard

                if store.profileState != .signedIn {
                    providerButtons
                }

                infoCard(title: "Preferences", items: store.profileModel.preferences)
                infoCard(title: "Privacy and data", items: store.profileModel.privacy)
                infoCard(title: "About", items: store.profileModel.about)
                debugCard
                dangerCard

                if store.profileState == .deleteConfirm {
                    DangerDialogView(
                        title: "Delete reminder data?",
                        bodyText: "删除会清空当前设备上的提醒偏好和送达记录，这个动作不可撤销。",
                        confirmTitle: "Confirm delete",
                        cancelTitle: "Cancel"
                    )
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .appPageBackground()
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(store.profileState == .signedIn ? "Signed in" : "Core features do not require login")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brandDeep)

            Text("Profile")
                .font(AppTypography.titleSection)
                .foregroundStyle(AppColor.textPrimary)

            Text(store.profileState == .signedIn ? store.profileModel.signedInSummary : store.profileModel.anonymousSummary)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            if store.profileState == .signedIn {
                Text(store.profileModel.providersText)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
            }
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private var providerButtons: some View {
        VStack(spacing: AppSpacing.sm) {
            AuthProviderButton(title: "Continue with Google", subtitle: "用于同步与恢复", icon: "globe", backgroundColor: AppColor.surface, foregroundColor: AppColor.textPrimary, showsBorder: true) {
                store.profileState = .signedIn
            }
            AuthProviderButton(title: "Continue with GitHub", subtitle: "开发者账号与历史恢复", icon: "chevron.left.forwardslash.chevron.right", backgroundColor: AppColor.textPrimary, foregroundColor: .white, showsBorder: false) {
                store.profileState = .signedIn
            }
            AuthProviderButton(title: "Continue with Apple", subtitle: "轻干预登录心智", icon: "apple.logo", backgroundColor: .black, foregroundColor: .white, showsBorder: false) {
                store.profileState = .signedIn
            }
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private func infoCard(title: String, items: [Phase3ProfileRow]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    HStack {
                        Text(item.title)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)
                        Spacer()
                        Text(item.value)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private var debugCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Phase 3 demo tools")
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)
            Text("统一调整主流程、tab 和页面状态，并打开 States & Overlays 目录。")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button("Open debug panel") {
                store.openDebugPanel()
            }
            .buttonStyle(.plain)
            .font(AppTypography.bodyStrong)
            .foregroundStyle(AppColor.brandDeep)
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private var dangerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Danger zone")
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)
            Text("危险操作单独分组，但不过度放大。")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                Button("Delete local data") {
                    store.profileState = .deleteConfirm
                }
                .buttonStyle(.plain)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.dangerDeep)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.danger, lineWidth: 1)
                )

                if store.profileState == .signedIn {
                    Button("Sign out") {
                        store.profileState = .anonymous
                    }
                    .buttonStyle(.plain)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
                }
            }
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }
}
