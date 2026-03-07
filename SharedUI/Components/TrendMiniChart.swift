import SwiftUI

struct TrendMiniChartItem: Identifiable, Hashable {
    let id: String
    let levelText: String
    let dateText: String
    let level: AppRiskLevel
}

struct TrendMiniChart: View {
    let items: [TrendMiniChartItem]

    var body: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.md) {
            ForEach(items) { item in
                VStack(spacing: AppSpacing.sm) {
                    Text(item.levelText)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(height: 32)

                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(RiskPalette.color(for: item.level))
                        .frame(width: 28, height: max(36, CGFloat(item.level.rawValue) * 24))

                    Text(item.dateText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
