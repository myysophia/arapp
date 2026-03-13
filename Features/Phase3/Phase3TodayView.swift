import SwiftUI

struct Phase3TodayView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                stateHeader
                content
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .appPageBackground()
    }

    private var stateHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(store.todayModel.cityName)
                .font(AppTypography.titleSection)
                .foregroundStyle(AppColor.textPrimary)

            Text("Phase 3 Today review")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch store.todayState {
        case .loading:
            StateView(type: .offline, title: "Loading today", bodyText: "首屏加载时保留结构与留白节奏，避免布局跳动。", ctaTitle: nil, onTapCTA: nil)
        case .empty:
            StateView(type: .empty, title: "No forecast yet", bodyText: "空态要保留页面层级，不要直接留白。", ctaTitle: "回到成功态") {
                store.todayState = .success
            }
        case .error:
            StateView(type: .error, title: "Could not refresh", bodyText: "错误只局部替换 Today 数据区域，不打断主流程。", ctaTitle: "重试") {
                store.todayState = .success
            }
        case .success, .stale, .offline:
            successContent
            if store.todayState == .stale {
                statusCard(text: "当前展示为最近一次成功结果。保留主结论与动作，但要明确这是陈旧缓存。")
            }
            if store.todayState == .offline {
                StateView(type: .offline, title: "Cached insight available", bodyText: "离线时继续展示最近一次成功结果，并保留重试入口。", ctaTitle: "重试") {
                    store.todayState = .success
                }
            }
        }
    }

    private var successContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            RiskHeroCard(
                eyebrow: "Today",
                title: store.todayModel.riskTitle,
                description: store.todayModel.riskDescription,
                badgeText: store.todayModel.badgeText,
                badgeColor: RiskPalette.color(for: store.todayModel.riskLevel),
                badgeForeground: RiskPalette.labelColor(for: store.todayModel.riskLevel),
                metrics: store.todayModel.metrics,
                primaryActionTitle: "Tune alerts"
            ) {
                store.selectedTab = .alerts
            }

            phase3Card(title: "Breakdown", subtitle: "Tree / Grass / Weed") {
                PollenBreakdownBar(items: store.todayModel.breakdownItems)
            }

            phase3Card(title: "3 day trend", subtitle: "保留轻量趋势，不做复杂仪表盘") {
                TrendMiniChart(items: store.todayModel.trendItems)
            }

            phase3Card(title: "Recommended actions", subtitle: "一个主建议，两个次建议") {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(store.todayModel.adviceItems) { item in
                        HStack(alignment: .top, spacing: AppSpacing.sm) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppColor.brand)
                                .frame(width: 22)

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(item.title)
                                    .font(AppTypography.bodyStrong)
                                    .foregroundStyle(AppColor.textPrimary)
                                Text(item.detail)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }
                    }
                }
            }

            phase3Card(title: "Source transparency", subtitle: "来源说明与免责声明") {
                SourceTransparencyCard(
                    providerName: store.todayModel.sourceProviderName,
                    sourceTypeLabel: store.todayModel.sourceTypeLabel,
                    coverageNote: store.todayModel.coverageNote,
                    licenseNote: store.todayModel.licenseNote,
                    updatedAtText: store.todayModel.updatedAtText,
                    disclaimer: store.todayModel.disclaimer
                )
            }
        }
    }

    private func phase3Card<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)
            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
        .padding(AppSpacing.lg)
        .appCardSurface()
    }

    private func statusCard(text: String) -> some View {
        Text(text)
            .font(AppTypography.body)
            .foregroundStyle(AppColor.textSecondary)
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardSurface()
    }
}
