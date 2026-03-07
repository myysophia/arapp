import SwiftUI

struct RiskHeroMetric: Identifiable, Hashable {
    let id: String
    let title: String
    let value: String
    let systemImage: String

    init(id: String? = nil, title: String, value: String, systemImage: String) {
        self.id = id ?? title
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }
}

struct RiskHeroCard: View {
    let eyebrow: String
    let title: String
    let description: String
    let badgeText: String
    let badgeColor: Color
    let badgeForeground: Color
    let metrics: [RiskHeroMetric]
    let primaryActionTitle: String
    let primaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(eyebrow)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)

                    Text(title)
                        .font(AppTypography.titleHero)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(description)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.md)

                Text(badgeText)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(badgeForeground)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(badgeColor, in: Capsule())
            }

            HStack(spacing: AppSpacing.md) {
                ForEach(metrics) { metric in
                    RiskHeroMetricChip(metric: metric)
                }
            }

            Button(action: primaryAction) {
                Text(primaryActionTitle)
                    .font(AppTypography.bodyStrong)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColor.surface)
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
        )
    }
}

private struct RiskHeroMetricChip: View {
    let metric: RiskHeroMetric

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: metric.systemImage)
                .font(.system(size: 13, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(AppTypography.caption)
                Text(metric.value)
                    .font(AppTypography.captionStrong)
            }
        }
        .foregroundStyle(AppColor.brandDeep)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.surfaceMuted, in: Capsule())
    }
}
