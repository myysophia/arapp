import SwiftUI

struct MapView: View {
    @Environment(AppState.self) private var appState

    private let state = MapScreenState.demo

    var body: some View {
        ZStack(alignment: .top) {
            MapCanvasView(state: state)
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: AppSpacing.sm) {
                MapSearchBar(state: state)
                MapCityBadge(cityName: state.selectedLocation.name)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)

            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: AppSpacing.md) {
                    Spacer()

                    MapFloatingActions()
                }
                .padding(.horizontal, AppSpacing.md)

                MapPointBottomSheet(state: state) {
                    appState.selectedTab = .alerts
                } secondaryAction: {
                    appState.selectedTab = .today
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
            }
        }
        .navigationTitle(AppTab.map.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MapCanvasView: View {
    let state: MapScreenState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xE8F3F2), Color(hex: 0xD2E5E3), Color(hex: 0xC8D8D3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            MapGridPattern()
                .opacity(0.2)

            Circle()
                .fill(RiskPalette.color(for: .veryHigh).opacity(0.26))
                .frame(width: 230, height: 230)
                .offset(x: 72, y: 58)
                .blur(radius: 4)

            Circle()
                .fill(RiskPalette.color(for: .moderate).opacity(0.24))
                .frame(width: 180, height: 180)
                .offset(x: -84, y: -46)
                .blur(radius: 6)

            Circle()
                .fill(RiskPalette.color(for: .low).opacity(0.2))
                .frame(width: 160, height: 160)
                .offset(x: -16, y: 210)
                .blur(radius: 5)

            ForEach(state.mapPoints) { point in
                MapPointMarker(point: point)
                    .offset(x: point.offset.width, y: point.offset.height)
            }
        }
        .overlay(alignment: .bottomLeading) {
            MapLegendView()
                .padding(.leading, AppSpacing.md)
                .padding(.bottom, 260)
        }
        .overlay(alignment: .topTrailing) {
            Button {
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .padding(.top, 104)
            .padding(.trailing, AppSpacing.md)
        }
    }
}

private struct MapGridPattern: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let step: CGFloat = 36
                for x in stride(from: 0, through: proxy.size.width, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                }
                for y in stride(from: 0, through: proxy.size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                }
            }
            .stroke(AppColor.textDisabled.opacity(0.18), lineWidth: 1)
        }
    }
}

private struct MapSearchBar: View {
    let state: MapScreenState

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSecondary)

            Text(state.searchPlaceholder)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()

            Text("3 个结果")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brandDeep)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

private struct MapCityBadge: View {
    let cityName: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "mappin.and.ellipse")
            Text(cityName)
        }
        .font(AppTypography.captionStrong)
        .foregroundStyle(AppColor.textPrimary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(.ultraThinMaterial, in: Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MapFloatingActions: View {
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            MapFloatingButton(systemImage: "location.fill")
            MapFloatingButton(systemImage: "square.3.layers.3d")
        }
    }
}

private struct MapFloatingButton: View {
    let systemImage: String

    var body: some View {
        Button {
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 48, height: 48)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
                .shadow(color: AppShadow.floatingColor, radius: AppShadow.floatingRadius, x: AppShadow.floatingX, y: AppShadow.floatingY)
        }
    }
}

private struct MapPointMarker: View {
    let point: MapPointState

    var body: some View {
        VStack(spacing: 0) {
            Text(point.level.displayText)
                .font(AppTypography.captionStrong)
                .foregroundStyle(RiskPalette.labelColor(for: point.level))
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(RiskPalette.color(for: point.level), in: Capsule())

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(RiskPalette.color(for: point.level))
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 6)
        }
    }
}

private struct MapLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("风险色阶")
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: 4) {
                legendBlock(.low)
                legendBlock(.moderate)
                legendBlock(.high)
                legendBlock(.veryHigh)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private func legendBlock(_ level: AppRiskLevel) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(RiskPalette.color(for: level))
            .frame(width: 28, height: 8)
    }
}

private struct MapPointBottomSheet: View {
    let state: MapScreenState
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Capsule()
                .fill(AppColor.line)
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(state.selectedLocation.name)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(state.summary.updatedAtText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: AppSpacing.md)

                Text(state.summary.riskTitle)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(state.summary.riskBadgeForeground)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(state.summary.riskBadgeColor, in: Capsule())
            }

            HStack(spacing: AppSpacing.sm) {
                MapSheetMetric(title: "树", level: state.summary.treeLevel.uiLevel)
                MapSheetMetric(title: "草", level: state.summary.grassLevel.uiLevel)
                MapSheetMetric(title: "杂草", level: state.summary.weedLevel.uiLevel)
            }

            HStack(spacing: AppSpacing.xs) {
                Text(state.summary.sourceTag)
                Text("主要城市模型覆盖")
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)

            Text("当前区域为模型推断结果，适合快速判断是否需要减少长时间户外暴露。")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.sm) {
                Button(action: primaryAction) {
                    Text("设为关注城市")
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))

                Button(action: secondaryAction) {
                    Text("查看今日详情")
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.brandDeep)
                .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(AppColor.surface)
                .shadow(color: AppShadow.floatingColor, radius: AppShadow.floatingRadius, x: AppShadow.floatingX, y: AppShadow.floatingY)
        )
    }
}

private struct MapSheetMetric: View {
    let title: String
    let level: AppRiskLevel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: 6) {
                Circle()
                    .fill(RiskPalette.color(for: level))
                    .frame(width: 8, height: 8)

                Text(level.displayText)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(AppColor.surfaceMuted, in: RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

private struct MapScreenState {
    let searchPlaceholder: String
    let selectedLocation: LocationSuggestion
    let summary: PollenSummary
    let source: SourceMeta
    let mapPoints: [MapPointState]

    static let demo = MapScreenState(
        searchPlaceholder: "搜索城市或区域",
        selectedLocation: LocationSuggestion(
            id: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00") ?? UUID(),
            name: "上海",
            countryCode: "CN",
            admin1: "上海市",
            lat: 31.2304,
            lng: 121.4737
        ),
        summary: PollenSummary(
            id: "map-summary-shanghai",
            cityName: "上海",
            locationID: UUID(uuidString: "6f222b19-b7c9-4baa-8661-2dd6905ddf00"),
            riskOverall: .high,
            treeLevel: .low,
            grassLevel: .high,
            weedLevel: .moderate,
            confidence: 0.82,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now,
            source: .model,
            isStale: false
        ),
        source: SourceMeta(
            id: UUID(uuidString: "8d11c444-0dd7-492d-a185-774bcc66a6f7") ?? UUID(),
            providerName: "Primary Model Provider",
            source: .model,
            coverageNote: "中国大陆主要城市模型覆盖",
            licenseNote: "仅用于风险参考，不代表采样监测",
            active: true,
            updatedAt: ISO8601DateFormatter().date(from: "2026-03-06T08:10:00Z") ?? .now
        ),
        mapPoints: [
            MapPointState(level: .veryHigh, offset: CGSize(width: 84, height: 24)),
            MapPointState(level: .high, offset: CGSize(width: -72, height: -52)),
            MapPointState(level: .moderate, offset: CGSize(width: 12, height: 154))
        ]
    )
}

private struct MapPointState: Identifiable {
    let id = UUID()
    let level: AppRiskLevel
    let offset: CGSize
}

private extension PollenSummary {
    var riskTitle: String {
        switch riskOverall {
        case .none:
            "风险很低"
        case .veryLow, .low:
            "低风险"
        case .moderate:
            "中等风险"
        case .high:
            "高风险"
        case .veryHigh:
            "极高风险"
        }
    }

    var riskBadgeColor: Color { RiskPalette.color(for: riskOverall.uiLevel) }
    var riskBadgeForeground: Color { RiskPalette.labelColor(for: riskOverall.uiLevel) }

    var updatedAtText: String {
        "更新于 \(updatedAt.relativeText)"
    }

    var sourceTag: String {
        source.displayText
    }
}

private extension PollenRiskLevel {
    var uiLevel: AppRiskLevel {
        AppRiskLevel(rawValue: rawValue) ?? .none
    }
}

private extension PollenSourceType {
    var displayText: String {
        switch self {
        case .model:
            "模型点"
        case .station:
            "监测站"
        case .vendor:
            "合作源"
        }
    }
}

private extension Date {
    var relativeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_Hans")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}

#Preview {
    NavigationStack {
        MapView()
            .environment(AppState())
    }
}
