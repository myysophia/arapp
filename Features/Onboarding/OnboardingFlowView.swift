import SwiftUI

struct OnboardingFlowView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0

    private let steps = [
        "onboarding.step.1",
        "onboarding.step.2",
        "onboarding.step.3"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(L10n.tr("onboarding.label"))
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)

            Text(L10n.tr(steps[currentStep]))
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
                Button(currentStep == steps.count - 1 ? L10n.tr("common.done") : L10n.tr("common.continue")) {
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button(L10n.tr("common.skip")) {
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
