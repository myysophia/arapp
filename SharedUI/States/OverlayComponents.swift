import SwiftUI

struct SearchSheetItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let badge: String
}

struct SearchSheetView: View {
    let placeholder: String
    let items: [SearchSheetItem]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            OverlayGrabber()

            TextField(placeholder, text: .constant(""))
                .textFieldStyle(.plain)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.line, lineWidth: 1)
                }
                .disabled(true)

            VStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    HStack(spacing: AppSpacing.sm) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(AppTypography.bodyStrong)
                                .foregroundStyle(AppColor.textPrimary)
                            Text(item.subtitle)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }

                        Spacer()

                        Text(item.badge)
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColor.brandDeep)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColor.surfaceMuted, in: Capsule())
                    }
                    .padding(AppSpacing.md)
                    .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(AppColor.line, lineWidth: 1)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(overlayBackground)
    }

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl)
            .fill(AppColor.surface.opacity(0.96))
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

struct SourceSheetView: View {
    let providerLabel: String
    let description: String
    let updatedAt: String
    let confidence: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            OverlayGrabber()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(L10n.tr("overlay.source.title"))
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(description)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.md)

                Text(providerLabel)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.brandDeep)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.surfaceMuted, in: Capsule())
            }

            HStack(spacing: AppSpacing.sm) {
                SourceMetaCard(title: L10n.tr("overlay.source.updated_at"), value: updatedAt)
                SourceMetaCard(title: L10n.tr("overlay.source.confidence"), value: confidence)
            }
        }
        .padding(AppSpacing.lg)
        .background(overlayBackground)
    }

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.xl)
            .fill(AppColor.surface.opacity(0.96))
            .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

private struct SourceMetaCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

struct DangerDialogView: View {
    let title: String
    let bodyText: String
    let confirmTitle: String
    let cancelTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(L10n.tr("overlay.danger.badge"))
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.danger)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColor.danger.opacity(0.1), in: Capsule())

            Text(title)
                .font(AppTypography.titleSection)
                .foregroundStyle(AppColor.textPrimary)

            Text(bodyText)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.sm) {
                Button(cancelTitle) {}
                    .buttonStyle(.plain)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))

                Button(confirmTitle) {}
                    .buttonStyle(.plain)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.danger, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.surface.opacity(0.98))
                .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
        )
    }
}

private struct OverlayGrabber: View {
    var body: some View {
        Capsule()
            .fill(AppColor.line)
            .frame(width: 44, height: 5)
            .frame(maxWidth: .infinity)
    }
}
