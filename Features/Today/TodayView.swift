import SwiftUI

struct TodayView: View {
    @Environment(AppState.self) private var appState

    private let state = TodayScreenState.demo

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                TodayHeader(summary: state.summary)
                RiskHeroCard(
                    eyebrow: "当前风险",
                    title: state.summary.riskTitle,
                    description: state.summary.riskDescription,
                    badgeText: state.summary.riskBadgeText,
                    badgeColor: state.summary.riskBadgeColor,
                    badgeForeground: state.summary.riskBadgeForeground,
                    metrics: state.summary.heroMetrics,
                    primaryActionTitle: "开启提醒"
                ) {
                    appState.selectedTab = .alerts
                }
                TodayBreakdownCard(summary: state.summary)
                TodayTrendCard(forecast: state.forecast)
                TodayAdviceCard(summary: state.summary, adviceItems: state.adviceItems)
                TodaySourceCard(source: state.source)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(AppTab.today.title)
        .navigationBarTitleDisplayMode(.large)
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

private struct TodayAdviceItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

private struct TodayScreenState {
    let summary: PollenSummary
    let forecast: PollenForecast
    let source: SourceMeta
    let adviceItems: [TodayAdviceItem]

    static let demo = TodayScreenState(
        summary: PollenSummary(
            id: "summary-shanghai-high",
            cityName: "上海",
            locationID: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00"),
            riskOverall: .high,
            treeLevel: .low,
            grassLevel: .high,
            weedLevel: .high,
            confidence: 0.84,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
            source: .model,
            isStale: false
        ),
        forecast: PollenForecast(
            days: [
                ForecastPoint(id: "2026-03-06", date: "2026-03-06", riskOverall: .high, treeLevel: .low, grassLevel: .high, weedLevel: .high),
                ForecastPoint(id: "2026-03-07", date: "2026-03-07", riskOverall: .veryHigh, treeLevel: .moderate, grassLevel: .veryHigh, weedLevel: .high),
                ForecastPoint(id: "2026-03-08", date: "2026-03-08", riskOverall: .moderate, treeLevel: .low, grassLevel: .moderate, weedLevel: .low)
            ]
        ),
        source: SourceMeta(
            id: UUID(uuidString: "8d11c444-0dd7-492d-a185-774bcc66a6f7") ?? UUID(),
            providerName: "Primary Model Provider",
            source: .model,
            coverageNote: "中国大陆主要城市模型覆盖",
            licenseNote: "仅用于风险参考，不代表采样监测",
            active: true,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
        ),
        adviceItems: [
            TodayAdviceItem(title: "减少高暴露时段外出", detail: "中午到傍晚风险更高，优先安排室内活动。", systemImage: "sun.max"),
            TodayAdviceItem(title: "回家后及时清洁", detail: "外出后更换外套并清洗面部，减少花粉残留。", systemImage: "drop"),
            TodayAdviceItem(title: "开启阈值提醒", detail: "当明天风险升高时，提前收到通知。", systemImage: "bell.badge")
        ]
    )
}

private extension PollenSummary {
    var uiLevel: AppRiskLevel { riskOverall.uiLevel }

    var riskTitle: String {
        switch riskOverall {
        case .none:
            "风险很低"
        case .veryLow, .low:
            "低风险"
        case .moderate:
            "中等风险"
        case .high:
            "高风险"
        case .veryHigh:
            "极高风险"
        }
    }

    var riskDescription: String {
        switch riskOverall {
        case .none:
            "今天的空气花粉影响较弱，日常活动基本不受影响。"
        case .veryLow, .low:
            "今天可以正常外出，但对花粉敏感人群仍建议保持观察。"
        case .moderate:
            "今天花粉水平正在抬升，建议缩短长时间户外停留。"
        case .high:
            "今天不建议长时间暴露在户外花粉环境中。"
        case .veryHigh:
            "今天建议尽量减少外出，并提前准备个人防护。"
        }
    }

    var riskBadgeText: String { uiLevel.displayText }
    var riskBadgeColor: Color { RiskPalette.color(for: uiLevel) }
    var riskBadgeForeground: Color { RiskPalette.labelColor(for: uiLevel) }

    var updatedAtText: String {
        "更新于 \(updatedAt.relativeText)"
    }

    var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    var sourceTag: String {
        source.displayText
    }

    var heroMetrics: [RiskHeroMetric] {
        var items = [
            RiskHeroMetric(
                title: "可信度",
                value: confidenceText,
                systemImage: "shield.lefthalf.filled"
            )
        ]

        if isStale {
            items.append(
                RiskHeroMetric(
                    title: "状态",
                    value: "更新较早",
                    systemImage: "clock.arrow.circlepath"
                )
            )
        } else {
            items.append(
                RiskHeroMetric(
                    title: "模型点",
                    value: sourceTag,
                    systemImage: "waveform.path.ecg"
                )
            )
        }

        return items
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
            "极低"
        case .veryLow:
            "很低"
        case .low:
            "较低"
        case .moderate:
            "中等"
        case .high:
            "较高"
        case .veryHigh:
            "极高"
        }
    }

    var progress: CGFloat {
        CGFloat(rawValue) / CGFloat(AppRiskLevel.veryHigh.rawValue)
    }
}

private extension PollenSourceType {
    var displayText: String {
        switch self {
        case .model:
            "模型点"
        case .station:
            "监测站"
        case .vendor:
            "合作源"
        }
    }
}

private extension ForecastPoint {
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans")
        formatter.dateFormat = "MM/dd"
        guard let parsed = ISO8601DateFormatter().date(from: date + "T00:00:00Z") else {
            return date
        }
        return formatter.string(from: parsed)
    }
}

private extension PollenForecast {
    var trendItems: [TrendMiniChartItem] {
        days.map { day in
            TrendMiniChartItem(
                id: day.id,
                levelText: day.riskOverall.uiLevel.displayText,
                dateText: day.displayDate,
                level: day.riskOverall.uiLevel
            )
        }
    }
}

private extension Date {
    var relativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_Hans")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}

#Preview {
    NavigationStack {
        TodayView()
            .environment(AppState())
    }
}
