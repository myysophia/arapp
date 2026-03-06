import SwiftUI

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0

    private let steps: [OnboardingStep] = [
        .init(
            eyebrow: "今日结论优先",
            title: "先看到今天是否危险，再决定要不要行动",
            subtitle: "首页先给出当前风险等级、三类花粉分项和一句行动建议，避免你一上来就看复杂图表。",
            accent: AppColor.brand,
            icon: "sun.max.fill",
            primaryTitle: "继续",
            secondaryTitle: "跳过",
            detailItems: ["首屏只保留一个主要结论", "默认显示今日更新时间", "基础能力无需登录"]
        ),
        .init(
            eyebrow: "位置权限",
            title: "允许定位后，首页和地图会直接落到你关心的城市",
            subtitle: "如果你暂时不授权，也仍然可以手动选城查看风险，不会阻断主流程。",
            accent: Color(hex: 0x0B7A75),
            icon: "location.fill",
            primaryTitle: "允许定位",
            secondaryTitle: "手动选城",
            detailItems: ["默认只上传降精度位置", "首版只绑定一个关注城市", "地图点位统一标记为模型点"]
        ),
        .init(
            eyebrow: "通知权限",
            title: "只在风险达到阈值时提醒一次，不做高频打扰",
            subtitle: "你可以稍后在提醒页设置阈值和静默时段。拒绝通知不会影响查看风险和调整配置。",
            accent: Color(hex: 0xB45309),
            icon: "bell.badge.fill",
            primaryTitle: "允许通知",
            secondaryTitle: "稍后设置",
            detailItems: ["每天最多一次风险提醒", "支持静默时段", "所有提醒文案都可回溯到来源说明"]
        )
    ]

    var body: some View {
        let step = steps[currentStep]

        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    heroCard(step: step)
                    detailCard(step: step)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }

            footer(step: step)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var topBar: some View {
        HStack {
            Text("欢迎使用")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()

            Button("跳过") {
                finish()
            }
            .font(AppTypography.bodyStrong)
            .foregroundStyle(AppColor.brand)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
    }

    private func heroCard(step: OnboardingStep) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text(step.eyebrow)
                .font(AppTypography.captionStrong)
                .foregroundStyle(step.accent)

            HStack(alignment: .top, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text(step.title)
                        .font(AppTypography.titleHero)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(step.subtitle)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)
            }

            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(step.accent.opacity(0.12))
                    .frame(height: 200)

                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(step.accent.opacity(0.18))
                            .frame(width: 96, height: 96)

                        Image(systemName: step.icon)
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(step.accent)
                    }

                    Text(step.primaryTitle)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(step.accent)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(.white.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shadow(
            color: AppShadow.cardColor,
            radius: AppShadow.cardRadius,
            x: AppShadow.cardX,
            y: AppShadow.cardY
        )
    }

    private func detailCard(step: OnboardingStep) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("本页会发生什么")
                .font(AppTypography.titleCard)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                ForEach(step.detailItems, id: \.self) { item in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(step.accent)

                        Text(item)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColor.textSecondary)

                        Spacer()
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private func footer(step: OnboardingStep) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(Array(steps.indices), id: \.self) { index in
                    Capsule()
                        .fill(index == currentStep ? step.accent : AppColor.line)
                        .frame(width: index == currentStep ? 28 : 10, height: 10)
                }
            }

            Button {
                advance()
            } label: {
                Text(step.primaryTitle)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(step.accent)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(step.secondaryTitle) {
                secondaryAction(for: currentStep)
            }
            .font(AppTypography.bodyStrong)
            .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.xl)
        .background(AppColor.background)
    }

    private func advance() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            finish()
        }
    }

    private func secondaryAction(for stepIndex: Int) {
        if stepIndex < steps.count - 1 {
            currentStep += 1
        } else {
            finish()
        }
    }

    private func finish() {
        appState.hasSeenOnboarding = true
        appState.route = nil
    }
}

private struct OnboardingStep {
    let eyebrow: String
    let title: String
    let subtitle: String
    let accent: Color
    let icon: String
    let primaryTitle: String
    let secondaryTitle: String
    let detailItems: [String]
}

#Preview {
    NavigationStack {
        OnboardingFlowView()
            .environment(AppState())
    }
}
