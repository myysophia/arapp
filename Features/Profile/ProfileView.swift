import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var authFlow: AuthFlowModel

    init(authFlow: AuthFlowModel = AuthFlowModel.shared) {
        _authFlow = State(initialValue: authFlow)
    }

    private var state: ProfileScreenState {
        ProfileScreenState(
            auth: authFlow.authMe,
            displayName: authFlow.displayName,
            defaultCity: L10n.tr("common.default_city"),
            versionLabel: L10n.tr("profile.version_label")
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                ProfileHeader(state: state, statusText: authFlow.statusChipText)

                if let errorMessage = authFlow.errorMessage {
                    AuthFlowNoticeCard(
                        title: L10n.tr("auth.error.title"),
                        detail: errorMessage,
                        systemImage: "exclamationmark.triangle"
                    ) {
                        authFlow.dismissError()
                    }
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
                LocaleOverrideCard(
                    localeIdentifier: appState.localeIdentifier,
                    onToggle: { appState.toggleLocale() }
                )
                PrivacySection(isAnonymous: state.isAnonymous)
                AboutSection(versionLabel: state.versionLabel)
                Phase3ReviewTools(
                    onOpenCatalog: { appState.openPhase3StatesCatalog() },
                    onOpenOnboarding: { appState.reopenOnboardingForReview() },
                    onOpenLogin: { appState.openLoginForReview() },
                    onJumpToTab: { appState.jumpToTab($0) }
                )
                DangerZone(isAnonymous: state.isAnonymous) {
                    Task {
                        await authFlow.signOut()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .appPageBackground()
        .navigationTitle(AppTab.profile.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await authFlow.bootstrapIfNeeded()
        }
    }
}

private struct ProfileHeader: View {
    let state: ProfileScreenState
    let statusText: String?

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

                if let statusText {
                    Text(statusText)
                        .font(AppTypography.captionStrong)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColor.surfaceMuted, in: Capsule())
                        .foregroundStyle(AppColor.brandDeep)
                }
            }

            if state.isAnonymous {
                Text(L10n.tr("profile.auth_not_required"))
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.surfaceMuted, in: Capsule())
            }
        }
    }
}

private struct AuthFlowNoticeCard: View {
    let title: String
    let detail: String
    let systemImage: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.warning)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(detail)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(L10n.tr("common.clear")) {
                onDismiss()
            }
            .buttonStyle(.plain)
            .font(AppTypography.captionStrong)
            .foregroundStyle(AppColor.brand)
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
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
                ProfileBadge(systemImage: "bell.badge", text: state.isAnonymous ? L10n.tr("profile.badge.local_only") : L10n.tr("profile.badge.sync_enabled"))
            }
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
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
        ProfileCardContainer(title: L10n.tr("profile.auth_options.title"), subtitle: L10n.tr("profile.auth_options.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                AuthProviderButton(
                    title: L10n.format("profile.auth_options.google.title", "Google"),
                    subtitle: L10n.tr("profile.auth_options.google.subtitle"),
                    icon: "globe",
                    backgroundColor: AppColor.surface,
                    foregroundColor: AppColor.textPrimary,
                    showsBorder: true,
                    onTap: onTapProvider
                )
                AuthProviderButton(
                    title: L10n.format("profile.auth_options.github.title", "GitHub"),
                    subtitle: L10n.tr("profile.auth_options.github.subtitle"),
                    icon: "chevron.left.forwardslash.chevron.right",
                    backgroundColor: AppColor.textPrimary,
                    foregroundColor: .white,
                    showsBorder: false,
                    onTap: onTapProvider
                )
                AuthProviderButton(
                    title: L10n.format("profile.auth_options.apple.title", "Apple"),
                    subtitle: L10n.tr("profile.auth_options.apple.subtitle"),
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
        ProfileCardContainer(title: L10n.tr("profile.providers.title"), subtitle: L10n.tr("profile.providers.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                ForEach(providers, id: \.rawValue) { provider in
                    HStack {
                        Label(provider.displayName, systemImage: provider.iconName)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)

                        Spacer()

                        Text(L10n.tr("common.connected"))
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
        ProfileCardContainer(title: L10n.tr("profile.preferences.title"), subtitle: L10n.tr("profile.preferences.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                PreferenceRow(title: L10n.tr("profile.preferences.language"), value: state.localeLabel, systemImage: "character.book.closed")
                PreferenceRow(title: L10n.tr("profile.preferences.unit"), value: state.unitLabel, systemImage: "scalemass")
                PreferenceRow(title: L10n.tr("profile.preferences.default_city"), value: state.defaultCity, systemImage: "location")
            }
        }
    }
}

private struct LocaleOverrideCard: View {
    let localeIdentifier: String
    let onToggle: () -> Void

    var body: some View {
        ProfileCardContainer(
            title: L10n.tr("profile.locale.title"),
            subtitle: L10n.tr("profile.locale.subtitle")
        ) {
            Button(action: onToggle) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(localeIdentifier == "zh-Hans" ? L10n.tr("locale.zh_hans") : L10n.tr("locale.en"))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)

                        Text(L10n.tr("profile.locale.action_hint"))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer()

                    Text(L10n.tr("profile.locale.toggle_action"))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.brandDeep)
                }
                .padding(AppSpacing.md)
                .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .buttonStyle(.plain)
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
        ProfileCardContainer(title: L10n.tr("profile.privacy.title"), subtitle: L10n.tr("profile.privacy.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                PrivacyRow(title: L10n.tr("profile.privacy.notifications.title"), detail: isAnonymous ? L10n.tr("profile.privacy.notifications.detail.anonymous") : L10n.tr("profile.privacy.notifications.detail.signed_in"))
                PrivacyRow(title: L10n.tr("profile.privacy.policy.title"), detail: L10n.tr("profile.privacy.policy.detail"))
                PrivacyRow(title: L10n.tr("profile.privacy.delete.title"), detail: L10n.tr("profile.privacy.delete.detail"))
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
        ProfileCardContainer(title: L10n.tr("profile.about.title"), subtitle: L10n.tr("profile.about.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                AboutRow(title: L10n.tr("profile.about.sources.title"), detail: L10n.tr("profile.about.sources.detail"))
                AboutRow(title: L10n.tr("profile.about.disclaimer.title"), detail: L10n.tr("profile.about.disclaimer.detail"))
                AboutRow(title: L10n.tr("profile.about.version.title"), detail: versionLabel)
            }
        }
    }
}

private struct Phase3ReviewTools: View {
    let onOpenCatalog: () -> Void
    let onOpenOnboarding: () -> Void
    let onOpenLogin: () -> Void
    let onJumpToTab: (AppTab) -> Void

    var body: some View {
        ProfileCardContainer(
            title: "Phase 3 review tools",
            subtitle: "统一打开状态目录、重走首屏流程，并快速切到四个主页面做手动验收。"
        ) {
            VStack(spacing: AppSpacing.sm) {
                reviewButton(
                    title: "Open states catalog",
                    subtitle: "查看 Search Sheet、Source Sheet、Danger Dialog 与核心异常态",
                    action: onOpenCatalog
                )

                reviewButton(
                    title: "Restart onboarding",
                    subtitle: "重新进入 Onboarding 三步与跳过路径",
                    action: onOpenOnboarding
                )

                reviewButton(
                    title: "Open login screen",
                    subtitle: "从 Profile 直接拉起 Login 流程，验证匿名与登录切换",
                    action: onOpenLogin
                )

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Quick tab jump")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)

                    HStack(spacing: AppSpacing.sm) {
                        ForEach(AppTab.allCases) { tab in
                            Button(tab.title) {
                                onJumpToTab(tab)
                            }
                            .buttonStyle(.plain)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColor.brandDeep)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColor.surfaceMuted, in: Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func reviewButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.textDisabled)
            }
            .padding(AppSpacing.md)
            .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
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
        ProfileCardContainer(title: L10n.tr("profile.danger.title"), subtitle: L10n.tr("profile.danger.subtitle")) {
            VStack(spacing: AppSpacing.sm) {
                Button(action: {}) {
                    Text(L10n.tr("profile.danger.delete"))
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
                        Text(L10n.tr("profile.danger.sign_out"))
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
        .appCardSurface()
    }
}

private struct ProfileScreenState {
    let auth: AuthMe
    let displayName: String
    let defaultCity: String
    let versionLabel: String

    var isAnonymous: Bool {
        auth.isAnonymous
    }

    var providers: [AuthProvider] {
        auth.providers
    }

    var localeLabel: String {
        auth.locale == "zh-Hans" ? L10n.tr("locale.zh_hans") : L10n.tr("locale.en")
    }

    var unitLabel: String {
        auth.unitSystem == .imperial ? L10n.tr("unit.imperial") : L10n.tr("unit.metric")
    }

    var headerTitle: String {
        isAnonymous ? L10n.tr("profile.header.title.anonymous") : L10n.tr("profile.header.title.signed_in")
    }

    var headerSubtitle: String {
        isAnonymous ? L10n.tr("profile.header.subtitle.anonymous") : L10n.tr("profile.header.subtitle.signed_in")
    }

    var accountSubtitle: String {
        isAnonymous
            ? L10n.tr("profile.account.subtitle.anonymous")
            : L10n.format("profile.account.subtitle.signed_in", providers.map(\.displayName).joined(separator: " / "))
    }
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
