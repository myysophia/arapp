import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    @State private var state = ProfileScreenState.anonymous

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                ProfileHeader(state: state) {
                    state = state.isAnonymous ? .signedIn : .anonymous
                }

                AccountStatusCard(state: state)

                if state.isAnonymous {
                    AuthButtonGroup {
                        appState.route = .login
                    }
                } else {
                    ProviderBindingCard(providers: state.providers)
                }

                PreferenceSection(state: state)
                PrivacySection(isAnonymous: state.isAnonymous)
                AboutSection(versionLabel: state.versionLabel)
                DangerZone(isAnonymous: state.isAnonymous) {
                    state = .anonymous
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(AppTab.profile.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct ProfileHeader: View {
    let state: ProfileScreenState
    let onTogglePreviewState: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(state.headerTitle)
                        .font(AppTypography.titleSection)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(state.headerSubtitle)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.md)

                Button(action: onTogglePreviewState) {
                    Text(state.isAnonymous ? "切到已登录预览" : "切到匿名预览")
                        .font(AppTypography.captionStrong)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColor.surfaceMuted, in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.brandDeep)
            }

            if state.isAnonymous {
                Text("基础功能无需登录")
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.surfaceMuted, in: Capsule())
            }
        }
    }
}

private struct AccountStatusCard: View {
    let state: ProfileScreenState

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(state.isAnonymous ? AppColor.surfaceMuted : AppColor.brand)
                        .frame(width: 60, height: 60)

                    Image(systemName: state.isAnonymous ? "person.crop.circle" : "person.crop.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(state.isAnonymous ? AppColor.brandDeep : .white)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(state.displayName)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(state.accountSubtitle)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: AppSpacing.sm) {
                ProfileBadge(systemImage: "globe.asia.australia", text: state.localeLabel)
                ProfileBadge(systemImage: "scalemass", text: state.unitLabel)
                ProfileBadge(systemImage: "bell.badge", text: state.isAnonymous ? "本地保存" : "可同步")
            }
        }
        .padding(AppSpacing.lg)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.lg)
            .fill(AppColor.surface)
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

private struct ProfileBadge: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
            Text(text)
                .font(AppTypography.captionStrong)
        }
        .foregroundStyle(AppColor.brandDeep)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.surfaceMuted, in: Capsule())
    }
}

private struct AuthButtonGroup: View {
    let onTapProvider: () -> Void

    var body: some View {
        ProfileCardContainer(title: "继续方式", subtitle: "登录仅用于同步提醒、语言和后续多设备配置。") {
            VStack(spacing: AppSpacing.sm) {
                AuthProviderButton(
                    title: "使用 Google 继续",
                    subtitle: "适合快速同步提醒设置",
                    icon: "globe",
                    backgroundColor: AppColor.surface,
                    foregroundColor: AppColor.textPrimary,
                    showsBorder: true,
                    onTap: onTapProvider
                )
                AuthProviderButton(
                    title: "使用 GitHub 继续",
                    subtitle: "适合保持开发者账号一致",
                    icon: "chevron.left.forwardslash.chevron.right",
                    backgroundColor: AppColor.textPrimary,
                    foregroundColor: .white,
                    showsBorder: false,
                    onTap: onTapProvider
                )
                AuthProviderButton(
                    title: "使用 Apple 继续",
                    subtitle: "保持 iOS 原生登录习惯",
                    icon: "apple.logo",
                    backgroundColor: .black,
                    foregroundColor: .white,
                    showsBorder: false,
                    onTap: onTapProvider
                )
            }
        }
    }
}

private struct ProviderBindingCard: View {
    let providers: [AuthProvider]

    var body: some View {
        ProfileCardContainer(title: "已绑定账号", subtitle: "登录成功后当前页面内刷新，不跳转新页。") {
            VStack(spacing: AppSpacing.sm) {
                ForEach(providers, id: \.rawValue) { provider in
                    HStack {
                        Label(provider.displayName, systemImage: provider.iconName)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)

                        Spacer()

                        Text("已连接")
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColor.brandDeep)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColor.surfaceMuted, in: Capsule())
                    }
                    .padding(AppSpacing.md)
                    .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
                }
            }
        }
    }
}

private struct PreferenceSection: View {
    let state: ProfileScreenState

    var body: some View {
        ProfileCardContainer(title: "偏好设置", subtitle: "修改后即时更新界面，并在后续接入服务端同步。") {
            VStack(spacing: AppSpacing.sm) {
                PreferenceRow(title: "语言", value: state.localeLabel, systemImage: "character.book.closed")
                PreferenceRow(title: "单位", value: state.unitLabel, systemImage: "scalemass")
                PreferenceRow(title: "默认城市", value: state.defaultCity, systemImage: "location")
            }
        }
    }
}

private struct PreferenceRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.brand)
                .frame(width: 20)

            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColor.textDisabled)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

private struct PrivacySection: View {
    let isAnonymous: Bool

    var body: some View {
        ProfileCardContainer(title: "隐私与数据", subtitle: "权限、隐私政策、数据删除都从这里直达。") {
            VStack(spacing: AppSpacing.sm) {
                PrivacyRow(title: "通知权限", detail: "\(isAnonymous ? "未同步" : "已关联账户") / 可跳转系统设置")
                PrivacyRow(title: "隐私政策", detail: "查看数据用途、保留周期和删除方式")
                PrivacyRow(title: "删除提醒数据", detail: "危险操作，必须二次确认")
            }
        }
    }
}

private struct PrivacyRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.textPrimary)

            Text(detail)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

private struct AboutSection: View {
    let versionLabel: String

    var body: some View {
        ProfileCardContainer(title: "关于与来源", subtitle: "来源透明和非医疗建议在这里统一呈现。") {
            VStack(spacing: AppSpacing.sm) {
                AboutRow(title: "数据来源", detail: "模型点 + 来源透明说明")
                AboutRow(title: "免责说明", detail: "仅提供风险参考，不构成医疗诊断")
                AboutRow(title: "版本号", detail: versionLabel)
            }
        }
    }
}

private struct AboutRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Text(detail)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

private struct DangerZone: View {
    let isAnonymous: Bool
    let onLogout: () -> Void

    var body: some View {
        ProfileCardContainer(title: "危险操作区", subtitle: "危险操作必须和普通按钮显著区分。") {
            VStack(spacing: AppSpacing.sm) {
                Button(action: {}) {
                    Text("删除提醒数据")
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.dangerDeep)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.danger, lineWidth: 1)
                )

                if !isAnonymous {
                    Button(action: onLogout) {
                        Text("退出登录")
                            .font(AppTypography.bodyStrong)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColor.textPrimary)
                    .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
                }
            }
        }
    }
}

private struct ProfileCardContainer<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.titleCard)
                    .foregroundStyle(AppColor.textPrimary)

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            content
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColor.surface)
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
        )
    }
}

private struct ProfileScreenState {
    let auth: AuthMe
    let displayName: String
    let defaultCity: String
    let versionLabel: String

    static let anonymous = ProfileScreenState(
        auth: .demoAnonymous,
        displayName: "匿名使用中",
        defaultCity: "上海",
        versionLabel: "Phase 1 Preview"
    )

    static let signedIn = ProfileScreenState(
        auth: .demoSignedIn,
        displayName: "王九日",
        defaultCity: "上海",
        versionLabel: "Phase 1 Preview"
    )

    var isAnonymous: Bool {
        auth.isAnonymous
    }

    var providers: [AuthProvider] {
        auth.providers
    }

    var localeLabel: String {
        auth.locale == "zh-Hans" ? "简体中文" : "English"
    }

    var unitLabel: String {
        auth.unitSystem == .imperial ? "Imperial" : "Metric"
    }

    var headerTitle: String {
        isAnonymous ? "管理你的偏好和账户状态" : "账户与偏好已同步"
    }

    var headerSubtitle: String {
        isAnonymous ? "你可以先匿名使用核心功能，再决定是否登录同步提醒。" : "当前页面集中管理语言、单位、隐私和数据来源说明。"
    }

    var accountSubtitle: String {
        isAnonymous ? "登录后可同步提醒设置与偏好，但基础功能无需登录。" : "已连接 \(providers.map(\.displayName).joined(separator: " / "))，偏好将跟随当前账户。"
    }
}

private extension AuthMe {
    static let demoAnonymous = AuthMe(userID: nil, isAnonymous: true, providers: [], locale: "zh-Hans", region: "CN", unitSystem: .metric)
    static let demoSignedIn = AuthMe(userID: UUID(), isAnonymous: false, providers: [.google, .apple], locale: "zh-Hans", region: "CN", unitSystem: .metric)
}

private extension AuthProvider {
    var displayName: String {
        switch self {
        case .google:
            "Google"
        case .github:
            "GitHub"
        case .apple:
            "Apple"
        }
    }

    var iconName: String {
        switch self {
        case .google:
            "globe"
        case .github:
            "chevron.left.forwardslash.chevron.right"
        case .apple:
            "apple.logo"
        }
    }
}
