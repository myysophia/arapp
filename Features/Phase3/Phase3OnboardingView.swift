import SwiftUI

struct Phase3OnboardingView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer(minLength: AppSpacing.lg)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("首次设置")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.brandDeep)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColor.surfaceMuted, in: Capsule())

                    Spacer()

                    Text("\(store.onboardingIndex + 1)/\(store.onboardingSteps.count)")
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)
                }

                HStack(spacing: AppSpacing.xs) {
                    ForEach(Array(store.onboardingSteps.indices), id: \.self) { index in
                        Capsule()
                            .fill(index == store.onboardingIndex ? AppColor.brand : AppColor.line)
                            .frame(width: index == store.onboardingIndex ? 30 : 12, height: 10)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)

            let step = store.onboardingSteps[store.onboardingIndex]
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AppColor.brandSoft)
                        .frame(width: 72, height: 72)

                    Image(systemName: step.icon)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(AppColor.brand)
                }

                Text(step.title)
                    .font(AppTypography.titleHero)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(step.body)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                if let stateNote {
                    StateView(
                        type: stateNote.type,
                        title: stateNote.title,
                        bodyText: stateNote.body,
                        ctaTitle: nil,
                        onTapCTA: nil
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.xl)
            .appCardSurface(cornerRadius: AppRadius.xl)

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Button(store.onboardingIndex == store.onboardingSteps.count - 1 ? "完成" : "继续") {
                    store.continueOnboarding()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .foregroundStyle(.white)

                Button("稍后") {
                    store.skipOnboarding()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .foregroundStyle(AppColor.brandDeep)
            }
            .font(AppTypography.bodyStrong)
            .padding(.bottom, AppSpacing.lg)
        }
        .padding(.horizontal, AppSpacing.md)
        .appPageBackground()
    }

    private var stateNote: (type: StateViewType, title: String, body: String)? {
        switch store.onboardingState {
        case .baseline:
            return nil
        case .locationDenied:
            return (.noPermission, "定位被拒绝", "即使用户拒绝定位，也允许手动选城并继续完成主流程。")
        case .notificationSkipped:
            return (.noNotification, "已跳过提醒", "提醒权限被跳过后，不阻断完成按钮，后续在 Alerts 内再设置阈值。")
        }
    }
}
