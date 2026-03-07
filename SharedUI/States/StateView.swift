import SwiftUI

enum StateViewType: Sendable {
    case empty
    case error
    case offline
    case noPermission
    case noNotification

    var iconName: String {
        switch self {
        case .empty:
            "tray"
        case .error:
            "exclamationmark.triangle"
        case .offline:
            "wifi.slash"
        case .noPermission:
            "location.slash"
        case .noNotification:
            "bell.slash"
        }
    }

    var accentColor: Color {
        switch self {
        case .empty:
            AppColor.brand
        case .error:
            AppColor.danger
        case .offline:
            AppColor.textSecondary
        case .noPermission:
            AppColor.warning
        case .noNotification:
            AppColor.brandDeep
        }
    }
}

struct StateView: View {
    let type: StateViewType
    let title: String
    let bodyText: String
    let ctaTitle: String?
    let onTapCTA: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(type.accentColor.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: type.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(type.accentColor)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.titleCard)
                    .foregroundStyle(AppColor.textPrimary)

                Text(bodyText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let ctaTitle, let onTapCTA {
                Button(action: onTapCTA) {
                    Text(ctaTitle)
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(type.accentColor, in: RoundedRectangle(cornerRadius: AppRadius.md))
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
