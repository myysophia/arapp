import SwiftUI

struct AlertsView: View {
    @Environment(AppState.self) private var appState

    @State private var state = AlertsScreenState.demo

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                AlertsHeader(state: state)
                AlertLocationCard(state: state)
                AlertToggleCard(isEnabled: state.subscription.enabled) { enabled in
                    state.subscription = state.subscription.withEnabled(enabled)
                }
                ThresholdSliderCard(level: state.subscription.thresholdLevel.uiLevel) { newLevel in
                    state.subscription = state.subscription.withThreshold(newLevel)
                }
                QuietHoursCard(quietHours: state.subscription.quietHours, isEnabled: state.subscription.enabled)
                AlertHistoryCard(items: state.history)

                if state.notificationPermission != .granted {
                    NotificationPermissionCard(permissionState: state.notificationPermission)
                }

                if state.auth.isAnonymous {
                    LoginSyncHintCard {
                        appState.route = .login
                    }
                }

                SaveSettingsButton(isEnabled: state.subscription.enabled) {
                    appState.selectedTab = .profile
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(AppTab.alerts.title)
        .navigationBarTitleDisplayMode(.large)
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
                    Text("关注城市")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)

                    Text(state.locationName)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("最近更新于 \(state.subscription.updatedAtText)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: AppSpacing.md)

                Text(state.subscription.enabled ? "已开启" : "已关闭")
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
            title: "提醒开关",
            subtitle: isEnabled ? "每天 07:00 检查阈值并在命中时推送" : "关闭后仍保留配置，但不会发送提醒"
        ) {
            Toggle(isOn: Binding(get: { isEnabled }, set: onToggle)) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(isEnabled ? "风险提醒已启用" : "风险提醒已关闭")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("通知权限与静默时段会影响最终触达")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .tint(AppColor.brand)
        }
    }
}

private struct ThresholdSliderCard: View {
    let level: AppRiskLevel
    let onChange: (AppRiskLevel) -> Void

    private let availableLevels: [AppRiskLevel] = [.none, .veryLow, .low, .moderate, .high, .veryHigh]

    var body: some View {
        AlertsCardContainer(title: "阈值设置", subtitle: "达到该等级及以上时触发提醒") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text("当前阈值")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(level.displayText)
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
        AlertsCardContainer(title: "静默时段", subtitle: quietHours.enabled ? quietHoursText : "当前未启用静默时段") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(quietHours.enabled ? "已开启" : "已关闭")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(quietHours.enabled ? "夜间抑制" : "随时提醒")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)
                }

                HStack(spacing: AppSpacing.md) {
                    QuietHoursPill(title: "开始", value: quietHours.start ?? "--:--")
                    QuietHoursPill(title: "结束", value: quietHours.end ?? "--:--")
                }

                Text(isEnabled ? "静默时段内命中阈值将延迟到下个可提醒窗口。" : "提醒关闭时仅展示当前配置，不触发推送。")
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
        AlertsCardContainer(title: "最近 7 天提醒记录", subtitle: "仅保留摘要，不展示原始 payload") {
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
        AlertsCardContainer(title: "通知权限", subtitle: permissionState.subtitle) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Label(permissionState.headline, systemImage: permissionState.systemImage)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Text("即使你已经保存阈值，系统权限未开启时也无法真正送达提醒。")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                Button(action: {}) {
                    Text("前往系统设置")
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
        AlertsCardContainer(title: "同步提醒设置", subtitle: "未登录时仅保存在本机") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("登录后可在未来支持跨设备同步提醒配置，但基础提醒功能本身不依赖登录。")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                Button(action: onLogin) {
                    Text("登录后可同步")
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
            Text(isEnabled ? "保存提醒设置" : "保存为关闭状态")
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

private struct AlertsScreenState {
    var auth: AuthMe
    var locationName: String
    var subscription: AlertSubscription
    var history: [AlertHistoryItem]
    var notificationPermission: AlertsNotificationPermission

    static let demo: AlertsScreenState = {
        AlertsScreenState(
            auth: .demoAnonymous,
            locationName: "上海",
            subscription: .demo,
            history: AlertHistoryItem.demoHistory,
            notificationPermission: .denied
        )
    }()

    var pageSummary: String {
        subscription.enabled ? "为高风险时刻提前准备" : "提醒已暂停，配置仍保留"
    }

    var pageDetail: String {
        auth.isAnonymous ? "当前设置先保存在本机，登录后可支持同步。" : "设置将在保存后同步到当前账户。"
    }

    var thresholdText: String {
        "阈值 \(subscription.thresholdLevel.uiLevel.displayText)"
    }

    var quietHoursText: String {
        subscription.quietHours.enabled ? "静默 \((subscription.quietHours.start ?? "--:--")) - \((subscription.quietHours.end ?? "--:--"))" : "未设置静默"
    }
}

private enum AlertsNotificationPermission {
    case granted
    case denied
    case notDetermined

    var headline: String {
        switch self {
        case .granted:
            "通知权限已开启"
        case .denied:
            "系统通知已关闭"
        case .notDetermined:
            "尚未授权通知"
        }
    }

    var subtitle: String {
        switch self {
        case .granted:
            "系统可正常触达提醒"
        case .denied:
            "需要先开启系统通知，提醒才会真正送达"
        case .notDetermined:
            "建议先授权，再保存提醒配置"
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

private extension AlertSubscription {
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
        updatedAt.formatted(.dateTime.month(.twoDigits).day(.twoDigits).hour().minute())
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

private extension AuthMe {
    static let demoAnonymous = AuthMe(userID: nil, isAnonymous: true, providers: [], locale: "zh-Hans", region: "CN", unitSystem: .metric)
}

private extension AlertHistoryItem {
    static let demoHistory: [AlertHistoryItem] = [
        AlertHistoryItem(id: UUID(), date: "2026-03-06T07:00:00Z", riskLevel: .high, title: "周五 07:00 草类花粉升至 4 级"),
        AlertHistoryItem(id: UUID(), date: "2026-03-04T07:00:00Z", riskLevel: .moderate, title: "周三 07:00 总体风险达到 3 级")
    ]

    var displayDate: String {
        guard let dateValue = ISO8601DateFormatter().date(from: date) else {
            return date
        }
        return dateValue.formatted(.dateTime.month(.twoDigits).day(.twoDigits).hour().minute())
    }
}

private extension PollenRiskLevel {
    var uiLevel: AppRiskLevel {
        AppRiskLevel(rawValue: rawValue) ?? .none
    }
}

private extension AppRiskLevel {
    var displayText: String {
        switch self {
        case .none:
            "0 级"
        case .veryLow:
            "1 级"
        case .low:
            "2 级"
        case .moderate:
            "3 级"
        case .high:
            "4 级"
        case .veryHigh:
            "5 级"
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
