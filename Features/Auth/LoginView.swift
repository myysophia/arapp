import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var authFlow = AuthFlowModel.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection

                if let errorMessage = authFlow.errorMessage {
                    loginStatusCard(
                        title: L10n.tr("auth.error.title"),
                        detail: errorMessage,
                        systemImage: "exclamationmark.triangle",
                        actionTitle: L10n.tr("common.clear")
                    ) {
                        authFlow.dismissError()
                    }
                }

                if authFlow.isAnonymous {
                    providerSection
                    anonymousSection
                } else {
                    signedInSection
                }

                trustSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xl)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(L10n.tr("auth.screen.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.tr("common.close")) {
                    appState.route = nil
                }
            }
        }
        .task {
            await authFlow.bootstrapIfNeeded()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColor.brand)
                    .frame(width: 68, height: 68)

                Image(systemName: authFlow.isAnonymous ? "leaf.circle.fill" : "checkmark.shield.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(authFlow.isAnonymous ? L10n.tr("auth.header.title.anonymous") : L10n.tr("auth.header.title.signed_in"))
                    .font(AppTypography.titleHero)
                    .foregroundStyle(AppColor.textPrimary)

                Text(authFlow.isAnonymous ? L10n.tr("auth.header.body.anonymous") : L10n.tr("auth.header.body.signed_in"))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            HStack(spacing: AppSpacing.xs) {
                benefitChip(title: L10n.tr("auth.benefit.sync_alerts"))
                benefitChip(title: L10n.tr("auth.benefit.keep_preferences"))
                benefitChip(title: authFlow.isSigningIn ? L10n.tr("auth.benefit.signing_in") : (authFlow.isAnonymous ? L10n.tr("auth.benefit.optional") : L10n.tr("auth.status.connected")))
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
            Text(L10n.tr("auth.provider.section_title"))
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            providerButton(for: .google, icon: "globe", backgroundColor: AppColor.surface, foregroundColor: AppColor.textPrimary, showsBorder: true)
            providerButton(for: .github, icon: "chevron.left.forwardslash.chevron.right", backgroundColor: AppColor.textPrimary, foregroundColor: .white, showsBorder: false)
            providerButton(for: .apple, icon: "apple.logo", backgroundColor: .black, foregroundColor: .white, showsBorder: false)
        }
    }

    private var anonymousSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {
                authFlow.continueAnonymously()
                appState.route = nil
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.tr("auth.anonymous.title"))
                            .font(AppTypography.bodyStrong)
                        Text(L10n.tr("auth.anonymous.subtitle"))
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
            .disabled(authFlow.isSigningIn)

            Text(L10n.tr("auth.anonymous.footnote"))
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var signedInSection: some View {
        loginStatusCard(
            title: L10n.tr("auth.success.title"),
            detail: L10n.tr("auth.success.detail"),
            systemImage: "person.crop.circle.badge.checkmark",
            actionTitle: L10n.tr("auth.success.action")
        ) {
            appState.selectedTab = .profile
            appState.route = nil
        }
    }

    private var trustSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(L10n.tr("auth.trust.section_title"))
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                trustRow(
                    icon: "bell.badge",
                    title: L10n.tr("auth.trust.sync_alerts.title"),
                    subtitle: L10n.tr("auth.trust.sync_alerts.subtitle")
                )
                trustRow(
                    icon: "lock.shield",
                    title: L10n.tr("auth.trust.optional.title"),
                    subtitle: L10n.tr("auth.trust.optional.subtitle")
                )
                trustRow(
                    icon: "info.circle",
                    title: L10n.tr("auth.trust.data_notice.title"),
                    subtitle: L10n.tr("auth.trust.data_notice.subtitle")
                )
            }
        }
    }

    private func providerButton(for provider: AuthProvider, icon: String, backgroundColor: Color, foregroundColor: Color, showsBorder: Bool) -> some View {
        LoginProviderButton(
            title: authFlow.providerTitle(provider),
            subtitle: authFlow.providerSubtitle(provider),
            icon: icon,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            showsBorder: showsBorder,
            isDisabled: authFlow.isSigningIn
        ) {
            Task {
                await authFlow.signIn(with: provider)
            }
        }
    }

    private func loginStatusCard(title: String, detail: String, systemImage: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.brand)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(detail)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(actionTitle) {
                action()
            }
            .buttonStyle(.plain)
            .font(AppTypography.bodyStrong)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .padding(AppSpacing.lg)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(
            color: AppShadow.cardColor,
            radius: AppShadow.cardRadius,
            x: AppShadow.cardX,
            y: AppShadow.cardY
        )
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
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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

                if isDisabled {
                    ProgressView()
                        .tint(foregroundColor)
                }
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
            .opacity(isDisabled ? 0.72 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environment(AppState())
    }
}
