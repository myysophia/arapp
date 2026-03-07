import SwiftUI

struct AuthProviderButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    let showsBorder: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.bodyStrong)
                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(foregroundColor.opacity(0.76))
                }

                Spacer()
            }
            .foregroundStyle(foregroundColor)
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(showsBorder ? AppColor.line : .clear, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
