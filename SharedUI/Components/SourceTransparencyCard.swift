import SwiftUI

struct SourceTransparencyCard: View {
    let providerName: String
    let sourceTypeLabel: String
    let coverageNote: String
    let licenseNote: String
    let updatedAtText: String
    let disclaimer: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(providerName)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Text(sourceTypeLabel)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.surfaceMuted, in: Capsule())
            }

            Text(coverageNote)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Text(licenseNote)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)

            Text(disclaimer)
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.textSecondary)

            Text(updatedAtText)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textDisabled)
        }
    }
}
