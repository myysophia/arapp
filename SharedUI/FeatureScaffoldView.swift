import SwiftUI

struct FeatureScaffoldView: View {
    let title: String
    let subtitle: String
    let primaryActionTitle: String
    var primaryAction: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle.weight(.bold))

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "rectangle.on.rectangle.angled")
                                .font(.system(size: 34))
                                .foregroundStyle(.secondary)

                            Text("这里是静态骨架占位")
                                .font(.headline)

                            Text("后续由页面组件、状态页和数据接线逐步替换。")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding(24)
                    }

                Button(primaryActionTitle) {
                    primaryAction?()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .navigationTitle(title)
    }
}
