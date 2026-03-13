import SwiftUI

struct Phase3AlertsView: View {
    @ObservedObject var store: Phase3DemoStore
    @State private var threshold: Double

    init(store: Phase3DemoStore) {
        self.store = store
        _threshold = State(initialValue: store.alertsModel.threshold)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                locationCard
                thresholdCard
                quietHoursCard

                if store.alertsState == .empty {
                    StateView(type: .empty, title: "No alerts yet", bodyText: "提醒为空时保留阈值与静默时段编辑，不把页面变成纯说明文档。", ctaTitle: "Create alert", onTapCTA: {})
                } else {
                    historyCard
                }

                if store.alertsState == .anonymous {
                    noticeCard(title: "Keep it anonymous for now", body: "阈值变化仍可本地保存，稍后再决定是否登录同步。")
                }

                if store.alertsState == .notificationsOff {
                    StateView(type: .noNotification, title: "Notifications are off", bodyText: "阈值编辑仍可用，但系统通知权限会影响送达。", ctaTitle: "Open settings", onTapCTA: {})
                }

                if store.alertsState == .error {
                    StateView(type: .error, title: "Could not save changes", bodyText: "错误态只覆盖局部反馈，不清空整页表单。", ctaTitle: "Retry", onTapCTA: {})
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .appPageBackground()
    }

    private var locationCard: some View {
        phase3Card(title: "Primary city", subtitle: store.alertsModel.summary) {
            HStack {
                Text(store.alertsModel.cityName)
                    .font(AppTypography.titleSection)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(store.alertsState == .anonymous ? "Local only" : "Sync ready")
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
            }
        }
    }

    private var thresholdCard: some View {
        phase3Card(title: "Threshold", subtitle: "先编辑阈值，再解释账号与通知能力") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Slider(value: $threshold, in: 0...5, step: 1)
                    .tint(RiskPalette.color(for: riskLevel))
                HStack {
                    Text("0")
                    Spacer()
                    Text("5")
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
                Text("Current level: \(Int(threshold))")
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }

    private var quietHoursCard: some View {
        phase3Card(title: "Quiet hours", subtitle: "保持静默时段为次层级") {
            Text(store.alertsModel.quietHours)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.brandDeep)
        }
    }

    private var historyCard: some View {
        phase3Card(title: "Recent 7-day activity", subtitle: "历史记录是次级信息，不抢阈值焦点") {
            VStack(spacing: AppSpacing.sm) {
                ForEach(store.alertsModel.history) { item in
                    HStack {
                        Text(item.time)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColor.textPrimary)
                        Spacer()
                        Text(item.level.displayText)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(RiskPalette.labelColor(for: item.level))
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(RiskPalette.color(for: item.level), in: Capsule())
                    }
                }
            }
        }
    }

    private func noticeCard(title: String, body: String) -> some View {
        phase3Card(title: title, subtitle: body) {
            EmptyView()
        }
    }

    private func phase3Card<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)
            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private var riskLevel: AppRiskLevel {
        AppRiskLevel(rawValue: Int(threshold)) ?? .none
    }
}
