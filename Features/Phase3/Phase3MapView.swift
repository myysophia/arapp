import SwiftUI

struct Phase3MapView: View {
    @ObservedObject var store: Phase3DemoStore

    var body: some View {
        ZStack(alignment: .top) {
            mapBackground
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: AppSpacing.sm) {
                searchBar
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)

            VStack {
                Spacer()
                bottomArea
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .appPageBackground()
    }

    @ViewBuilder
    private var mapBackground: some View {
        switch store.mapState {
        case .noLocation:
            StateView(type: .noPermission, title: "Location stays optional", bodyText: "定位关闭时仍保留地图入口与手动搜索，不把用户踢出主流程。", ctaTitle: "Choose city", onTapCTA: {})
                .padding(.horizontal, AppSpacing.md)
        case .offline:
            StateView(type: .offline, title: "Cached heat field available", bodyText: "离线时继续显示最近一次成功热区，并显式标注缓存语义。", ctaTitle: "Retry", onTapCTA: {
                store.mapState = .selected
            })
            .padding(.horizontal, AppSpacing.md)
        default:
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0xE8F3F2), Color(hex: 0xD2E5E3), Color(hex: 0xC8D8D3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(RiskPalette.color(for: .veryHigh).opacity(0.26))
                    .frame(width: 220, height: 220)
                    .offset(x: 70, y: -30)

                Circle()
                    .fill(RiskPalette.color(for: .moderate).opacity(0.24))
                    .frame(width: 180, height: 180)
                    .offset(x: -80, y: 30)

                Circle()
                    .fill(RiskPalette.color(for: .low).opacity(0.20))
                    .frame(width: 160, height: 160)
                    .offset(x: 10, y: 150)
            }
        }
    }

    private var searchBar: some View {
        Button {
            store.mapState = store.mapState == .searchSheet ? .coverage : .searchSheet
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search city")
                Spacer()
                Text(store.mapModel.selectedCity)
            }
            .font(AppTypography.body)
            .foregroundStyle(AppColor.textSecondary)
            .padding(AppSpacing.md)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var bottomArea: some View {
        VStack(spacing: AppSpacing.sm) {
            if store.mapState == .searchSheet {
                SearchSheetView(
                    placeholder: "搜索城市、区县或拼音",
                    items: [
                        SearchSheetItem(id: "sh", title: "上海市", subtitle: "Shanghai, CN", badge: "最近访问"),
                        SearchSheetItem(id: "hz", title: "杭州市", subtitle: "Hangzhou, CN", badge: "华东"),
                        SearchSheetItem(id: "sz", title: "苏州市", subtitle: "Suzhou, CN", badge: "推荐")
                    ]
                )
            }

            if store.mapState == .sourceSheet {
                SourceSheetView(
                    providerLabel: store.mapModel.providerLabel,
                    description: store.mapModel.sourceDescription,
                    updatedAt: store.mapModel.updatedAt,
                    confidence: store.mapModel.confidence
                )
            }

            if store.mapState == .selected || store.mapState == .sourceSheet {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(store.mapModel.pointName)
                                .font(AppTypography.titleSection)
                                .foregroundStyle(AppColor.textPrimary)
                            Text("Updated \(store.mapModel.updatedAt)")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }

                        Spacer()

                        Text("Model point")
                            .font(AppTypography.captionStrong)
                            .foregroundStyle(AppColor.brandDeep)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColor.surfaceMuted, in: Capsule())
                    }

                    Text(store.mapModel.pointSummary)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)

                    PollenBreakdownBar(
                        items: [
                            PollenBreakdownItem(title: "Tree", level: .high),
                            PollenBreakdownItem(title: "Grass", level: .moderate),
                            PollenBreakdownItem(title: "Weed", level: .low)
                        ]
                    )

                    HStack {
                        Button("Set as primary city") {}
                            .buttonStyle(.plain)
                            .font(AppTypography.bodyStrong)
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(AppColor.brand, in: RoundedRectangle(cornerRadius: AppRadius.md))

                        Button("Open today") {
                            store.selectedTab = .today
                        }
                        .buttonStyle(.plain)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.brandDeep)

                        Spacer()

                        Button(store.mapState == .sourceSheet ? "Hide source" : "Source notes") {
                            store.mapState = store.mapState == .sourceSheet ? .selected : .sourceSheet
                        }
                        .buttonStyle(.plain)
                        .font(AppTypography.captionStrong)
                        .foregroundStyle(AppColor.textSecondary)
                    }
                }
                .padding(AppSpacing.lg)
                .appCardSurface(cornerRadius: AppRadius.xl)
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Map coverage")
                        .font(AppTypography.titleCard)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("Tap a model point to reveal source notes and today shortcuts.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardSurface(cornerRadius: AppRadius.xl)
            }
        }
    }
}
