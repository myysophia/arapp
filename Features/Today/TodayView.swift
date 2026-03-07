import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @State private var screenModel: TodayScreenModel

    init(screenModel: TodayScreenModel = TodayScreenModel()) {
        _screenModel = State(initialValue: screenModel)
    }

    private var dataModeBinding: Binding<TodayScreenModel.DataMode> {
        Binding(
            get: { screenModel.dataMode },
            set: { screenModel.dataMode = $0 }
        )
    }

    private var mockScenarioBinding: Binding<TodayScreenModel.MockScenario> {
        Binding(
            get: { screenModel.mockScenario },
            set: { screenModel.mockScenario = $0 }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                TodayModeCard(
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
        .navigationTitle(AppTab.today.title)
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
            TodayLoadingCard()
        case let .empty(title, detail):
            TodayStatusCard(
                title: title,
                detail: detail,
                systemImage: "tray",
                tintColor: AppColor.textSecondary,
                actionTitle: "切回 Mock 成功态",
                action: {
                    screenModel.dataMode = .mock
                    screenModel.mockScenario = .success
                }
            )
        case let .failure(title, detail, retryable):
            TodayStatusCard(
                title: title,
                detail: detail,
                systemImage: "wifi.exclamationmark",
                tintColor: AppColor.danger,
                actionTitle: retryable ? "重新加载" : nil,
                action: retryable ? { Task { await screenModel.reload() } } : nil
            )
        case let .success(screenState):
            TodaySuccessContent(screenState: screenState, openAlerts: {
                appState.selectedTab = .alerts
            })
        }
    }
}

private struct TodayModeCard: View {
    @Binding var dataMode: TodayScreenModel.DataMode
    @Binding var mockScenario: TodayScreenModel.MockScenario
    let reloadAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("数据模式")
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Today 页面支持 Mock 和 Client 两条数据链路。")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Button("重载") {
                    reloadAction()
                }
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brand)
            }

            Picker("数据模式", selection: $dataMode) {
                ForEach(TodayScreenModel.DataMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if dataMode == .mock {
                Picker("Mock 场景", selection: $mockScenario) {
                    ForEach(TodayScreenModel.MockScenario.allCases) { scenario in
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

private struct TodaySuccessContent: View {
    let screenState: TodayScreenState
    let openAlerts: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            TodayHeader(summary: screenState.summary)
            RiskHeroCard(
                eyebrow: "当前风险",
                title: screenState.summary.riskTitle,
                description: screenState.summary.riskDescription,
                badgeText: screenState.summary.riskBadgeText,
                badgeColor: screenState.summary.riskBadgeColor,
                badgeForeground: screenState.summary.riskBadgeForeground,
                metrics: screenState.summary.heroMetrics,
                primaryActionTitle: "开启提醒"
            ) {
                openAlerts()
            }
            TodayBreakdownCard(summary: screenState.summary)
            TodayTrendCard(forecast: screenState.forecast)
            TodayAdviceCard(summary: screenState.summary, adviceItems: screenState.adviceItems)
            TodaySourceCard(source: screenState.source)
        }
    }
}

private struct TodayHeader: View {
    let summary: PollenSummary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(summary.cityName)
                .font(AppTypography.titleSection)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: AppSpacing.xs) {
                Label(summary.updatedAtText, systemImage: "clock")
                Text(summary.sourceTag)
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)
        }
    }
}

private struct TodayBreakdownCard: View {
    let summary: PollenSummary

    var body: some View {
        TodayCardContainer(title: "分项概览", subtitle: "树 / 草 / 杂草") {
            VStack(spacing: AppSpacing.md) {
                TodayBreakdownRow(title: "树", level: summary.treeLevel.uiLevel)
                TodayBreakdownRow(title: "草", level: summary.grassLevel.uiLevel)
                TodayBreakdownRow(title: "杂草", level: summary.weedLevel.uiLevel)
            }
        }
    }
}

private struct TodayBreakdownRow: View {
    let title: String
    let level: AppRiskLevel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(title)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Text(level.displayText)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.textSecondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppRadius.pill)
                        .fill(AppColor.line)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: AppRadius.pill)
                        .fill(RiskPalette.color(for: level))
                        .frame(width: max(proxy.size.width * level.progress, 10), height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

private struct TodayTrendCard: View {
    let forecast: PollenForecast

    var body: some View {
        TodayCardContainer(title: "未来 3 天趋势", subtitle: trendSummary) {
            TrendMiniChart(items: forecast.trendItems)
        }
    }

    private var trendSummary: String {
        guard let peakDay = forecast.days.max(by: { $0.riskOverall.rawValue < $1.riskOverall.rawValue }) else {
            return "保持观察"
        }

        return "高峰出现在 \(peakDay.displayDate)"
    }
}

private struct TodayAdviceCard: View {
    let summary: PollenSummary
    let adviceItems: [TodayAdviceItem]

    var body: some View {
        TodayCardContainer(title: "行动建议", subtitle: summary.riskDescription) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(adviceItems) { item in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColor.brand)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColor.textPrimary)

                            Text(item.detail)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
}

private struct TodaySourceCard: View {
    let source: SourceMeta

    var body: some View {
        TodayCardContainer(title: "数据来源", subtitle: "风险参考，非医疗建议") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text(source.providerName)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(source.source.displayText)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.brandDeep)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColor.surfaceMuted, in: Capsule())
                }

                Text(source.coverageNote)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                Text(source.licenseNote)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)

                Text("更新于 \(source.updatedAt.relativeText)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textDisabled)
            }
        }
    }
}

private struct TodayLoadingCard: View {
    var body: some View {
        TodayCardContainer(title: "正在加载 Today 页面", subtitle: "读取 summary / forecast / source meta") {
            HStack(spacing: AppSpacing.md) {
                ProgressView()
                    .tint(AppColor.brand)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("正在同步花粉风险数据")
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("如果你切到 Client 模式，页面会优先尝试读取 Edge Functions。")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()
            }
        }
    }
}

private struct TodayStatusCard: View {
    let title: String
    let detail: String
    let systemImage: String
    let tintColor: Color
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        TodayCardContainer(title: title, subtitle: detail) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tintColor)
                        .frame(width: 28, height: 28)

                    Text(detail)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let actionTitle, let action {
                    Button(actionTitle) {
                        action()
                    }
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.brand, in: Capsule())
                }
            }
        }
    }
}

private struct TodayCardContainer<Content: View>: View {
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

#Preview {
    NavigationStack {
        TodayView()
            .environment(AppState())
    }
}
