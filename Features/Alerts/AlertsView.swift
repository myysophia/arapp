import SwiftUI

struct AlertsView: View {
    @Environment(AppState.self) private var appState
    @State private var screenModel: AlertsScreenModel

    init(screenModel: AlertsScreenModel = AlertsScreenModel()) {
        _screenModel = State(initialValue: screenModel)
    }

    private var dataModeBinding: Binding<AlertsScreenModel.DataMode> {
        Binding(
            get: { screenModel.dataMode },
            set: { screenModel.dataMode = $0 }
        )
    }

    private var mockScenarioBinding: Binding<AlertsScreenModel.MockScenario> {
        Binding(
            get: { screenModel.mockScenario },
            set: { screenModel.mockScenario = $0 }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                AlertsModeCard(
                    dataMode: dataModeBinding,
                    mockScenario: mockScenarioBinding,
                    reloadAction: { Task { await screenModel.reload() } }
                )
                contentSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(AppTab.alerts.title)
        .navigationBarTitleDisplayMode(.large)
        .task(id: screenModel.reloadKey) {
            await screenModel.reload()
        }
        .refreshable {
            await screenModel.reload()
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        switch screenModel.contentState {
        case .loading:
            AlertsStatusCard(
                title: L10n.tr("alerts.loading.title"),
                detail: L10n.tr("alerts.loading.detail"),
                systemImage: "bell.badge"
            )
        case let .empty(title, detail):
            AlertsStatusCard(
                title: title,
                detail: detail,
                systemImage: "tray",
                actionTitle: L10n.tr("alerts.action.back_to_configured"),
                action: {
                    screenModel.dataMode = .mock
                    screenModel.mockScenario = .configured
                }
            )
        case let .failure(title, detail, retryable):
            AlertsStatusCard(
                title: title,
                detail: detail,
                systemImage: "wifi.exclamationmark",
                actionTitle: retryable ? L10n.tr("common.reload") : nil,
                action: retryable ? { Task { await screenModel.reload() } } : nil
            )
        case let .success(state):
            AlertsConfiguredContent(
                state: state,
                onToggle: { value in
                    Task { await screenModel.updateEnabled(value) }
                },
                onThresholdChange: { value in
                    Task { await screenModel.updateThreshold(value) }
                },
                onLogin: { appState.route = .login },
                onSave: { appState.selectedTab = .profile }
            )
        }
    }
}

private struct AlertsModeCard: View {
    @Binding var dataMode: AlertsScreenModel.DataMode
    @Binding var mockScenario: AlertsScreenModel.MockScenario
    let reloadAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(L10n.tr("alerts.mode.title"))
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(L10n.tr("alerts.mode.subtitle"))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Button(L10n.tr("common.reload")) {
                    reloadAction()
                }
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brand)
            }

            Picker(L10n.tr("alerts.mode.picker"), selection: $dataMode) {
                ForEach(AlertsScreenModel.DataMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if dataMode == .mock {
                Picker(L10n.tr("alerts.scenario.picker"), selection: $mockScenario) {
                    ForEach(AlertsScreenModel.MockScenario.allCases) { scenario in
                        Text(scenario.title).tag(scenario)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColor.surface)
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
        )
    }
}

private struct AlertsConfiguredContent: View {
    let state: AlertsScreenState
    let onToggle: (Bool) -> Void
    let onThresholdChange: (AppRiskLevel) -> Void
    let onLogin: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            AlertsHeader(state: state)
            AlertLocationCard(state: state)
            AlertToggleCard(isEnabled: state.subscription.enabled, onToggle: onToggle)
            ThresholdSliderCard(level: state.subscription.thresholdLevel.uiLevel, onChange: onThresholdChange)
            QuietHoursCard(quietHours: state.subscription.quietHours, isEnabled: state.subscription.enabled)
            AlertHistoryCard(items: state.history)

            if state.notificationPermission != .granted {
                NotificationPermissionCard(permissionState: state.notificationPermission)
            }

            if state.auth.isAnonymous {
                LoginSyncHintCard(onLogin: onLogin)
            }

            SaveSettingsButton(isEnabled: state.subscription.enabled, onSave: onSave)
        }
    }
}

private struct AlertsStatusCard: View {
    let title: String
    let detail: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, detail: String, systemImage: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        AlertsCardContainer(title: title, subtitle: detail) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Label(title, systemImage: systemImage)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Text(detail)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let actionTitle, let action {
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
            }
        }
    }
}

private struct AlertsHeader: View {
    let state: AlertsScreenState

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(state.pageSummary)
                .font(AppTypography.titleSection)
                .foregroundStyle(AppColor.textPrimary)

            Text(state.pageDetail)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

private struct AlertLocationCard: View {
    let state: AlertsScreenState

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(L10n.tr("alerts.location.title"))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)

                    Text(state.locationName)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(L10n.format("alerts.location.updated_at", state.subscription.updatedAtText))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: AppSpacing.md)

                Text(state.subscription.enabled ? L10n.tr("common.enabled") : L10n.tr("common.disabled"))
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(state.subscription.enabled ? .white : AppColor.textSecondary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        state.subscription.enabled ? AppColor.brand : AppColor.surfaceMuted,
                        in: Capsule()
                    )
            }

            HStack(spacing: AppSpacing.sm) {
                AlertBadge(systemImage: "bell.badge.fill", text: state.thresholdText)
                AlertBadge(systemImage: "moon.stars.fill", text: state.quietHoursText)
            }
        }
        .padding(AppSpacing.lg)
        .background(alertCardBackground)
    }

    private var alertCardBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.lg)
            .fill(AppColor.surface)
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

private struct AlertBadge: View {
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

private struct AlertToggleCard: View {
    let isEnabled: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        AlertsCardContainer(
            title: L10n.tr("alerts.toggle.title"),
            subtitle: isEnabled ? L10n.tr("alerts.toggle.subtitle.enabled") : L10n.tr("alerts.toggle.subtitle.disabled")
        ) {
            Button {
                onToggle(!isEnabled)
            } label: {
                HStack(spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(isEnabled ? L10n.tr("alerts.toggle.headline.enabled") : L10n.tr("alerts.toggle.headline.disabled"))
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)

                        Text(L10n.tr("alerts.toggle.helper"))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer()

                    ZStack(alignment: isEnabled ? .trailing : .leading) {
                        Capsule()
                            .fill(isEnabled ? AppColor.brand : AppColor.line)
                            .frame(width: 52, height: 32)

                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .padding(2)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ThresholdSliderCard: View {
    let level: AppRiskLevel
    let onChange: (AppRiskLevel) -> Void

    private let availableLevels: [AppRiskLevel] = [.none, .veryLow, .low, .moderate, .high, .veryHigh]

    var body: some View {
        AlertsCardContainer(title: L10n.tr("alerts.threshold.title"), subtitle: L10n.tr("alerts.threshold.subtitle")) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(L10n.tr("alerts.threshold.current"))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(level.thresholdDisplayText)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(level.badgeForeground)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(level.badgeColor, in: Capsule())
                }

                HStack(spacing: AppSpacing.xs) {
                    ForEach(availableLevels, id: \.rawValue) { candidate in
                        Button {
                            onChange(candidate)
                        } label: {
                            VStack(spacing: AppSpacing.xs) {
                                Circle()
                                    .fill(candidate.badgeColor)
                                    .frame(width: 16, height: 16)
                                    .overlay {
                                        if candidate == level {
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                                .padding(2)
                                        }
                                    }

                                Text("\(candidate.rawValue)")
                                    .font(AppTypography.captionStrong)
                                    .foregroundStyle(candidate == level ? AppColor.textPrimary : AppColor.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(candidate == level ? AppColor.surfaceMuted : AppColor.surface)
                                    .stroke(candidate == level ? AppColor.brand : AppColor.line, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct QuietHoursCard: View {
    let quietHours: QuietHours
    let isEnabled: Bool

    var body: some View {
        AlertsCardContainer(title: L10n.tr("alerts.quiet_hours.title"), subtitle: quietHours.enabled ? quietHoursText : L10n.tr("alerts.quiet_hours.subtitle.disabled")) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(quietHours.enabled ? L10n.tr("common.enabled") : L10n.tr("common.disabled"))
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(quietHours.enabled ? L10n.tr("alerts.quiet_hours.badge.enabled") : L10n.tr("alerts.quiet_hours.badge.disabled"))
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)
                }

                HStack(spacing: AppSpacing.md) {
                    QuietHoursPill(title: L10n.tr("common.start"), value: quietHours.start ?? "--:--")
                    QuietHoursPill(title: L10n.tr("common.end"), value: quietHours.end ?? "--:--")
                }

                Text(isEnabled ? L10n.tr("alerts.quiet_hours.detail.enabled") : L10n.tr("alerts.quiet_hours.detail.disabled"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .opacity(isEnabled ? 1 : 0.55)
        }
    }

    private var quietHoursText: String {
        [quietHours.start, quietHours.end]
            .compactMap { $0 }
            .joined(separator: " - ")
    }
}

private struct QuietHoursPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(value)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

private struct AlertHistoryCard: View {
    let items: [AlertHistoryItem]

    var body: some View {
        AlertsCardContainer(title: L10n.tr("alerts.history.title"), subtitle: L10n.tr("alerts.history.subtitle")) {
            VStack(spacing: AppSpacing.md) {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Circle()
                            .fill(item.riskLevel.uiLevel.badgeColor)
                            .frame(width: 12, height: 12)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(item.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(item.displayDate)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

private struct NotificationPermissionCard: View {
    let permissionState: AlertsNotificationPermission

    var body: some View {
        AlertsCardContainer(title: L10n.tr("alerts.permission.title"), subtitle: permissionState.subtitle) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Label(permissionState.headline, systemImage: permissionState.systemImage)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Text(L10n.tr("alerts.permission.detail"))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                Button(action: {}) {
                    Text(L10n.tr("alerts.permission.action"))
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.brandDeep)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.brand, lineWidth: 1)
                )
            }
        }
    }
}

private struct LoginSyncHintCard: View {
    let onLogin: () -> Void

    var body: some View {
        AlertsCardContainer(title: L10n.tr("alerts.sync.title"), subtitle: L10n.tr("alerts.sync.subtitle")) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(L10n.tr("alerts.sync.detail"))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                Button(action: onLogin) {
                    Text(L10n.tr("alerts.sync.action"))
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
    }
}

private struct SaveSettingsButton: View {
    let isEnabled: Bool
    let onSave: () -> Void

    var body: some View {
        Button(action: onSave) {
            Text(isEnabled ? L10n.tr("alerts.save.enabled") : L10n.tr("alerts.save.disabled"))
                .font(AppTypography.bodyStrong)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(AppColor.brandDeep, in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .padding(.top, AppSpacing.xs)
    }
}

private struct AlertsCardContainer<Content: View>: View {
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

struct AlertsScreenState {
    var auth: AuthMe
    var locationName: String
    var subscription: AlertSubscription
    var history: [AlertHistoryItem]
    var notificationPermission: AlertsNotificationPermission

    static let demo: AlertsScreenState = {
        AlertsScreenState(
            auth: .demoAnonymous,
            locationName: L10n.tr("common.default_city"),
            subscription: .demo,
            history: AlertHistoryItem.demoHistory,
            notificationPermission: .denied
        )
    }()

    var pageSummary: String {
        subscription.enabled ? L10n.tr("alerts.page_summary.enabled") : L10n.tr("alerts.page_summary.disabled")
    }

    var pageDetail: String {
        auth.isAnonymous ? L10n.tr("alerts.page_detail.anonymous") : L10n.tr("alerts.page_detail.signed_in")
    }

    var thresholdText: String {
        L10n.format("alerts.threshold.badge", subscription.thresholdLevel.uiLevel.thresholdDisplayText)
    }

    var quietHoursText: String {
        subscription.quietHours.enabled
            ? L10n.format("alerts.quiet_hours.badge", subscription.quietHours.start ?? "--:--", subscription.quietHours.end ?? "--:--")
            : L10n.tr("alerts.quiet_hours.none")
    }
}

enum AlertsNotificationPermission {
    case granted
    case denied
    case notDetermined

    var headline: String {
        switch self {
        case .granted:
            L10n.tr("alerts.permission.headline.granted")
        case .denied:
            L10n.tr("alerts.permission.headline.denied")
        case .notDetermined:
            L10n.tr("alerts.permission.headline.not_determined")
        }
    }

    var subtitle: String {
        switch self {
        case .granted:
            L10n.tr("alerts.permission.subtitle.granted")
        case .denied:
            L10n.tr("alerts.permission.subtitle.denied")
        case .notDetermined:
            L10n.tr("alerts.permission.subtitle.not_determined")
        }
    }

    var systemImage: String {
        switch self {
        case .granted:
            "bell.badge"
        case .denied:
            "bell.slash"
        case .notDetermined:
            "bell"
        }
    }
}

extension AuthMe {
    static let demoAnonymous = AuthMe(userID: nil, isAnonymous: true, providers: [], locale: "zh-Hans", region: "CN", unitSystem: .metric)
    static let demoSignedIn = AuthMe(userID: UUID(), isAnonymous: false, providers: [.apple], locale: "zh-Hans", region: "CN", unitSystem: .metric)
}

extension AlertSubscription {
    static let demo = AlertSubscription(
        id: UUID(),
        userID: nil,
        locationID: UUID(),
        thresholdLevel: .moderate,
        enabled: true,
        quietHours: QuietHours(enabled: true, start: "22:00", end: "07:00"),
        updatedAt: .now
    )

    var updatedAtText: String {
        AppFormatters.shortDateTime(updatedAt)
    }

    func withEnabled(_ enabled: Bool) -> AlertSubscription {
        AlertSubscription(
            id: id,
            userID: userID,
            locationID: locationID,
            thresholdLevel: thresholdLevel,
            enabled: enabled,
            quietHours: quietHours,
            updatedAt: updatedAt
        )
    }

    func withThreshold(_ level: AppRiskLevel) -> AlertSubscription {
        AlertSubscription(
            id: id,
            userID: userID,
            locationID: locationID,
            thresholdLevel: level.modelLevel,
            enabled: enabled,
            quietHours: quietHours,
            updatedAt: updatedAt
        )
    }
}

private extension AlertHistoryItem {
    static let demoHistory: [AlertHistoryItem] = [
        AlertHistoryItem(id: UUID(), date: "2026-03-06T07:00:00Z", riskLevel: .high, title: L10n.tr("alerts.history.demo.1")),
        AlertHistoryItem(id: UUID(), date: "2026-03-04T07:00:00Z", riskLevel: .moderate, title: L10n.tr("alerts.history.demo.2"))
    ]

    var displayDate: String {
        guard let dateValue = ISO8601DateFormatter().date(from: date) else {
            return date
        }
        return AppFormatters.shortDateTime(dateValue)
    }
}

private extension AppRiskLevel {
    var thresholdDisplayText: String {
        switch self {
        case .none:
            L10n.tr("alerts.level.0")
        case .veryLow:
            L10n.tr("alerts.level.1")
        case .low:
            L10n.tr("alerts.level.2")
        case .moderate:
            L10n.tr("alerts.level.3")
        case .high:
            L10n.tr("alerts.level.4")
        case .veryHigh:
            L10n.tr("alerts.level.5")
        }
    }

    var badgeColor: Color {
        RiskPalette.color(for: self)
    }

    var badgeForeground: Color {
        RiskPalette.labelColor(for: self)
    }

    var modelLevel: PollenRiskLevel {
        PollenRiskLevel(rawValue: rawValue) ?? .none
    }
}
