import SwiftUI

struct MapView: View {
    @Environment(AppState.self) private var appState
    @State private var screenModel: MapScreenModel

    init(screenModel: MapScreenModel = MapScreenModel()) {
        _screenModel = State(initialValue: screenModel)
    }

    private var dataModeBinding: Binding<MapScreenModel.DataMode> {
        Binding(
            get: { screenModel.dataMode },
            set: { screenModel.dataMode = $0 }
        )
    }

    private var mockScenarioBinding: Binding<MapScreenModel.MockScenario> {
        Binding(
            get: { screenModel.mockScenario },
            set: { screenModel.mockScenario = $0 }
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            mapBackground
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: AppSpacing.sm) {
                MapModeBar(
                    dataMode: dataModeBinding,
                    mockScenario: mockScenarioBinding,
                    reloadAction: { Task { await screenModel.reload() } }
                )
                topControls
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)

            VStack {
                Spacer()
                floatingActions
                bottomSheetArea
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)

            overlaySheets
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(AppTab.map.title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: screenModel.reloadKey) {
            await screenModel.reload()
        }
    }

    @ViewBuilder
    private var mapBackground: some View {
        switch screenModel.contentState {
        case .loading:
            ZStack {
                mapCanvasBackground
                StateView(
                    type: .offline,
                    title: L10n.tr("map.loading.title"),
                    bodyText: L10n.tr("map.loading.detail"),
                    ctaTitle: nil,
                    onTapCTA: nil
                )
                .padding(.horizontal, AppSpacing.md)
            }
        case let .failure(title, detail, retryable):
            ZStack {
                mapCanvasBackground
                StateView(
                    type: .error,
                    title: title,
                    bodyText: detail,
                    ctaTitle: retryable ? L10n.tr("common.retry") : nil,
                    onTapCTA: retryable ? { Task { await screenModel.reload() } } : nil
                )
                .padding(.horizontal, AppSpacing.md)
            }
        case let .success(state):
            MapCanvasView(
                state: state,
                selectedPointID: screenModel.selectedPointID,
                onSelectPoint: { screenModel.selectPoint($0) },
                onOpenSource: { screenModel.toggleSourceSheet() }
            )
        }
    }

    private var topControls: some View {
        VStack(spacing: AppSpacing.sm) {
            Button {
                screenModel.toggleSearchSheet()
            } label: {
                if case let .success(state) = screenModel.contentState {
                    MapSearchBar(state: state)
                } else {
                    MapDisabledSearchBar()
                }
            }
            .buttonStyle(.plain)

            if case let .success(state) = screenModel.contentState {
                MapCityBadge(cityName: state.selectedLocation.name)
            }
        }
    }

    private var floatingActions: some View {
        HStack(alignment: .bottom, spacing: AppSpacing.md) {
            Spacer()
            MapFloatingActions(
                onLocate: {},
                onOpenLegend: { screenModel.toggleSourceSheet() }
            )
        }
    }

    @ViewBuilder
    private var bottomSheetArea: some View {
        if case let .success(state) = screenModel.contentState,
           let selectedPoint = state.selectedPoint(using: screenModel.selectedPointID) {
            MapPointBottomSheet(
                selectedLocationName: selectedPoint.locationName,
                summary: selectedPoint.summary,
                source: state.source,
                primaryAction: { appState.selectedTab = .alerts },
                secondaryAction: { appState.selectedTab = .today }
            )
        }
    }

    @ViewBuilder
    private var overlaySheets: some View {
        if case let .success(state) = screenModel.contentState {
            if screenModel.isSearchSheetPresented || screenModel.isSourceSheetPresented {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .onTapGesture {
                        screenModel.isSearchSheetPresented = false
                        screenModel.isSourceSheetPresented = false
                    }
            }

            VStack {
                Spacer()

                if screenModel.isSearchSheetPresented {
                    SearchSheetView(
                        placeholder: state.searchPlaceholder,
                        items: state.searchItems
                    )
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 220)
                }

                if screenModel.isSourceSheetPresented {
                    SourceSheetView(
                        providerLabel: state.source.providerName,
                        description: state.source.coverageNote,
                        updatedAt: state.source.updatedAt.relativeText,
                        confidence: selectedConfidenceText(in: state)
                    )
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, 220)
                }
            }
            .animation(.spring(response: 0.28, dampingFraction: 0.88), value: screenModel.isSearchSheetPresented)
            .animation(.spring(response: 0.28, dampingFraction: 0.88), value: screenModel.isSourceSheetPresented)
        }
    }

    private func selectedConfidenceText(in state: MapScreenState) -> String {
        guard let selectedPoint = state.selectedPoint(using: screenModel.selectedPointID) else {
            return "--"
        }
        return "\(Int(selectedPoint.summary.confidence * 100))%"
    }

    private var mapCanvasBackground: some View {
        LinearGradient(
            colors: [Color(hex: 0xE8F3F2), Color(hex: 0xD2E5E3), Color(hex: 0xC8D8D3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            MapGridPattern()
                .opacity(0.2)
        }
    }
}

private struct MapModeBar: View {
    @Binding var dataMode: MapScreenModel.DataMode
    @Binding var mockScenario: MapScreenModel.MockScenario
    let reloadAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(L10n.tr("map.mode.title"))
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(L10n.tr("map.mode.subtitle"))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Button(L10n.tr("common.reload")) {
                    reloadAction()
                }
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brand)
            }

            Picker(L10n.tr("map.mode.picker"), selection: $dataMode) {
                ForEach(MapScreenModel.DataMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if dataMode == .mock {
                Picker(L10n.tr("map.scenario.picker"), selection: $mockScenario) {
                    ForEach(MapScreenModel.MockScenario.allCases) { scenario in
                        Text(scenario.title).tag(scenario)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(AppSpacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

private struct MapCanvasView: View {
    let state: MapScreenState
    let selectedPointID: UUID?
    let onSelectPoint: (UUID) -> Void
    let onOpenSource: () -> Void

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
                Button {
                    onSelectPoint(point.id)
                } label: {
                    MapPointMarker(
                        point: point,
                        isSelected: point.id == selectedPointID
                    )
                }
                .buttonStyle(.plain)
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
                onOpenSource()
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .padding(.top, 160)
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

            Text(L10n.format("map.search.result_count", state.searchItems.count))
                .font(AppTypography.captionStrong)
                .foregroundStyle(AppColor.brandDeep)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppShadow.cardColor, radius: AppShadow.cardRadius, x: AppShadow.cardX, y: AppShadow.cardY)
    }
}

private struct MapDisabledSearchBar: View {
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textSecondary)
            Text(L10n.tr("map.search.disabled"))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppRadius.lg))
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
    let onLocate: () -> Void
    let onOpenLegend: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            MapFloatingButton(systemImage: "location.fill", action: onLocate)
            MapFloatingButton(systemImage: "square.3.layers.3d", action: onOpenLegend)
        }
    }
}

private struct MapFloatingButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(point.summary.riskOverall.uiLevel.displayText)
                .font(AppTypography.captionStrong)
                .foregroundStyle(RiskPalette.labelColor(for: point.summary.riskOverall.uiLevel))
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(RiskPalette.color(for: point.summary.riskOverall.uiLevel), in: Capsule())

            Image(systemName: isSelected ? "mappin.circle.fill" : "mappin.circle")
                .font(.system(size: 28))
                .foregroundStyle(RiskPalette.color(for: point.summary.riskOverall.uiLevel))
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 6)
        }
        .scaleEffect(isSelected ? 1.06 : 1)
    }
}

private struct MapLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(L10n.tr("map.legend.title"))
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
    let selectedLocationName: String
    let summary: PollenSummary
    let source: SourceMeta
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
                    Text(selectedLocationName)
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(summary.updatedAtText)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: AppSpacing.md)

                Text(summary.mapRiskTitle)
                    .font(AppTypography.captionStrong)
                    .foregroundStyle(summary.mapRiskBadgeForeground)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(summary.mapRiskBadgeColor, in: Capsule())
            }

            HStack(spacing: AppSpacing.sm) {
                MapSheetMetric(title: L10n.tr("pollen.tree"), level: summary.treeLevel.uiLevel)
                MapSheetMetric(title: L10n.tr("pollen.grass"), level: summary.grassLevel.uiLevel)
                MapSheetMetric(title: L10n.tr("pollen.weed"), level: summary.weedLevel.uiLevel)
            }

            HStack(spacing: AppSpacing.xs) {
                Text(summary.sourceTag)
                Text(source.coverageNote)
                    .lineLimit(1)
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)

            Text(L10n.tr("map.sheet.detail"))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.sm) {
                Button(action: primaryAction) {
                    Text(L10n.tr("map.sheet.primary_action"))
                        .font(AppTypography.bodyStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))

                Button(action: secondaryAction) {
                    Text(L10n.tr("map.sheet.secondary_action"))
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

#Preview {
    NavigationStack {
        MapView()
            .environment(AppState())
    }
}
