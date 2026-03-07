import SwiftUI

struct StatesCatalogView: View {
    private let searchItems: [SearchSheetItem] = [
        SearchSheetItem(id: "sh", title: "上海市", subtitle: "Shanghai, CN", badge: "最近访问"),
        SearchSheetItem(id: "hz", title: "杭州市", subtitle: "Hangzhou, CN", badge: "华东"),
        SearchSheetItem(id: "sz", title: "苏州市", subtitle: "Suzhou, CN", badge: "推荐")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("状态页与弹层")
                    .font(AppTypography.titleHero)
                    .foregroundStyle(AppColor.textPrimary)

                VStack(spacing: AppSpacing.md) {
                    StateView(
                        type: .noPermission,
                        title: "定位未开启",
                        bodyText: "拒绝定位后不阻断主流程，转为手动选城并解释不会上送实时坐标。",
                        ctaTitle: "手动选择城市",
                        onTapCTA: {}
                    )

                    StateView(
                        type: .offline,
                        title: "网络不可用",
                        bodyText: "优先展示最近一次有效缓存，明确更新时间，并限制交互到可恢复范围。",
                        ctaTitle: "查看缓存结果",
                        onTapCTA: {}
                    )

                    StateView(
                        type: .empty,
                        title: "提醒为空",
                        bodyText: "还未设置阈值时，只保留一个主操作，避免界面说明过载。",
                        ctaTitle: "设置提醒阈值",
                        onTapCTA: {}
                    )
                }

                SearchSheetView(placeholder: "搜索城市、区县或拼音", items: searchItems)

                SourceSheetView(
                    providerLabel: "MODEL",
                    description: "当前结果来自模型点推断，而不是站点实测。适合趋势判断，不适合作为医疗结论。",
                    updatedAt: "07:10",
                    confidence: "0.81"
                )

                DangerDialogView(
                    title: "删除提醒数据？",
                    bodyText: "删除后会清空当前账户下的设备令牌、提醒订阅与最近送达记录。这个动作不可撤销。",
                    confirmTitle: "确认删除",
                    cancelTitle: "取消"
                )
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("状态目录")
    }
}

#Preview {
    NavigationStack {
        StatesCatalogView()
    }
}
