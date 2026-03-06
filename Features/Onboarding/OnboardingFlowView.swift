import SwiftUI

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0

    private let steps = [
        "把花粉风险变成今天就能执行的提醒",
        "允许定位，让首页和地图直接落到你关心的城市",
        "允许通知，在高风险到来前收到一次简洁提醒"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Onboarding")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Text(steps[currentStep])
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            HStack(spacing: 8) {
                ForEach(Array(steps.indices), id: \.self) { index in
                    Capsule()
                        .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.2))
                        .frame(width: index == currentStep ? 28 : 10, height: 10)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button(currentStep == steps.count - 1 ? "完成" : "继续") {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("跳过") {
                    finish()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func advance() {
        if currentStep < steps.count - 1 {
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
