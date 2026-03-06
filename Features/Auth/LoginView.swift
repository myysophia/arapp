import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection
                providerSection
                anonymousSection
                trustSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xl)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("登录")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("关闭") {
                    appState.route = nil
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColor.brand)
                    .frame(width: 68, height: 68)

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("登录后同步你的提醒设置")
                    .font(AppTypography.titleHero)
                    .foregroundStyle(AppColor.textPrimary)

                Text("基础花粉风险查看无需登录。登录仅用于同步提醒、语言和后续多设备配置。")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            HStack(spacing: AppSpacing.xs) {
                benefitChip(title: "同步提醒")
                benefitChip(title: "保留偏好")
                benefitChip(title: "后续支持多设备")
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(
            color: AppShadow.cardColor,
            radius: AppShadow.cardRadius,
            x: AppShadow.cardX,
            y: AppShadow.cardY
        )
    }

    private var providerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("继续方式")
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            LoginProviderButton(
                title: "使用 Google 继续",
                subtitle: "适合需要快速同步设置的用户",
                icon: "globe",
                backgroundColor: AppColor.surface,
                foregroundColor: AppColor.textPrimary,
                showsBorder: true
            )

            LoginProviderButton(
                title: "使用 GitHub 继续",
                subtitle: "适合开发者账号体系保持一致",
                icon: "chevron.left.forwardslash.chevron.right",
                backgroundColor: AppColor.textPrimary,
                foregroundColor: .white,
                showsBorder: false
            )

            LoginProviderButton(
                title: "使用 Apple 继续",
                subtitle: "遵循 iOS 原生登录习惯",
                icon: "apple.logo",
                backgroundColor: .black,
                foregroundColor: .white,
                showsBorder: false
            )
        }
    }

    private var anonymousSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {
                appState.route = nil
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("先匿名继续")
                            .font(AppTypography.bodyStrong)
                        Text("稍后仍可从“我的”页面绑定账号")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.brand)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity)
                .background(AppColor.surfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)

            Text("当前阶段仅提供静态流程展示，真实认证会在后续接入 Supabase Auth。")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var trustSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("你将看到什么")
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                trustRow(
                    icon: "bell.badge",
                    title: "提醒同步",
                    subtitle: "让风险阈值和静默时段跟账号走。"
                )
                trustRow(
                    icon: "lock.shield",
                    title: "非强制登录",
                    subtitle: "风险浏览、地图和基础提醒能力默认可匿名使用。"
                )
                trustRow(
                    icon: "info.circle",
                    title: "数据说明",
                    subtitle: "登录不会改变数据来源与非医疗建议的展示规则。"
                )
            }
        }
    }

    private func benefitChip(title: String) -> some View {
        Text(title)
            .font(AppTypography.captionStrong)
            .foregroundStyle(AppColor.brandDeep)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(AppColor.surfaceMuted)
            .clipShape(Capsule())
    }

    private func trustRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.brand)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }
}

private struct LoginProviderButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    let showsBorder: Bool

    var body: some View {
        Button(action: {}) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(foregroundColor.opacity(0.76))
                }

                Spacer()
            }
            .foregroundStyle(foregroundColor)
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(showsBorder ? AppColor.line : .clear, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(AppState())
    }
}
