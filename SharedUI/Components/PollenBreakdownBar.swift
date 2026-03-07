import SwiftUI

struct PollenBreakdownItem: Identifiable, Hashable {
    let id: String
    let title: String
    let level: AppRiskLevel

    init(id: String? = nil, title: String, level: AppRiskLevel) {
        self.id = id ?? title
        self.title = title
        self.level = level
    }
}

struct PollenBreakdownBar: View {
    let items: [PollenBreakdownItem]

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(item.title)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(AppColor.textPrimary)

                        Spacer()

                        Text(item.level.displayText)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: AppRadius.pill)
                                .fill(AppColor.line)
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: AppRadius.pill)
                                .fill(RiskPalette.color(for: item.level))
                                .frame(width: max(proxy.size.width * item.level.progress, 10), height: 10)
                        }
                    }
                    .frame(height: 10)
                }
            }
        }
    }
}
