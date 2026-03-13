import Foundation

enum Phase3MockFixtures {
    static let login = Phase3LoginModel(
        title: "Follow the air, not the noise.",
        subtitle: "Phase 3 只验证导航、交互、状态切换与界面结构，不依赖真实登录与真实数据。",
        anonymousTitle: "先匿名继续",
        anonymousSubtitle: "先进入主流程，稍后再决定是否需要同步。",
        errorMessage: "登录暂时失败。保留匿名继续，不把用户困在首屏。"
    )

    static let today = Phase3TodayModel(
        cityName: "Shanghai",
        riskTitle: "High pollen pressure",
        riskDescription: "今天优先减少长时间户外暴露，把决定压缩成一个主结论和一个主动作。",
        riskLevel: .high,
        badgeText: "Risk 4",
        metrics: [
            RiskHeroMetric(title: "Updated", value: "08:30", systemImage: "clock"),
            RiskHeroMetric(title: "Confidence", value: "72%", systemImage: "waveform.path.ecg"),
            RiskHeroMetric(title: "City", value: "Shanghai", systemImage: "location")
        ],
        breakdownItems: [
            PollenBreakdownItem(title: "Tree", level: .high),
            PollenBreakdownItem(title: "Grass", level: .moderate),
            PollenBreakdownItem(title: "Weed", level: .low)
        ],
        trendItems: [
            TrendMiniChartItem(id: "today", levelText: "High", dateText: "Today", level: .high),
            TrendMiniChartItem(id: "tomorrow", levelText: "Moderate", dateText: "Tomorrow", level: .moderate),
            TrendMiniChartItem(id: "day3", levelText: "Low", dateText: "Day 3", level: .low)
        ],
        adviceItems: [
            Phase3AdviceItem(id: "1", title: "Reduce long exposure", detail: "把高强度户外活动后移到傍晚，避免在峰值时段逗留。", systemImage: "figure.walk"),
            Phase3AdviceItem(id: "2", title: "Keep medication ready", detail: "如果已有方案，通勤前把缓解手段准备好。", systemImage: "cross.case"),
            Phase3AdviceItem(id: "3", title: "Use alerts as backup", detail: "把阈值提醒当作补位，减少频繁手动刷新。", systemImage: "bell.badge")
        ],
        sourceProviderName: "ArApp blended forecast",
        sourceTypeLabel: "Forecast blend",
        coverageNote: "模型推断与预报融合结果，适合趋势判断，不应误导为监测站实况。",
        licenseNote: "Model-derived guidance only. This is not medical advice.",
        updatedAtText: "Updated 08:30",
        disclaimer: "Direction only. Not a medical recommendation."
    )

    static let map = Phase3MapModel(
        selectedCity: "Shanghai",
        pointName: "Jing'an",
        pointSummary: "内环热区仍偏高，地图先传达覆盖范围，再用抽屉解释点位含义和来源语义。",
        providerLabel: "MODEL",
        sourceDescription: "当前结果来自模型点推断，不是站点实测。适合趋势判断，不适合作为医疗结论。",
        updatedAt: "08:30",
        confidence: "72%"
    )

    static let alerts = Phase3AlertsModel(
        cityName: "Shanghai",
        summary: "阈值编辑优先于账号与通知配置，匿名态和通知关闭都不能阻断设置。",
        quietHours: "22:00 - 07:00",
        threshold: 4,
        history: [
            Phase3AlertsHistoryItem(id: "1", time: "03-09 06:30", level: .high),
            Phase3AlertsHistoryItem(id: "2", time: "03-08 07:10", level: .veryHigh),
            Phase3AlertsHistoryItem(id: "3", time: "03-07 08:20", level: .moderate)
        ]
    )

    static let profile = Phase3ProfileModel(
        anonymousSummary: "登录只用于同步与恢复。基础花粉判断、地图查看与本地提醒都可以先匿名体验。",
        signedInSummary: "账号已连接。提醒与偏好在当前设备和未来的同步链路上保持一致语义。",
        providersText: "Google + Apple",
        preferences: [
            Phase3ProfileRow(id: "language", title: "Language", value: "System"),
            Phase3ProfileRow(id: "unit", title: "Unit", value: "Metric"),
            Phase3ProfileRow(id: "city", title: "Primary city", value: "Shanghai")
        ],
        privacy: [
            Phase3ProfileRow(id: "permissions", title: "Permissions", value: "Location + Notifications"),
            Phase3ProfileRow(id: "policy", title: "Privacy policy", value: "Open"),
            Phase3ProfileRow(id: "delete", title: "Delete data", value: "Requires confirmation")
        ],
        about: [
            Phase3ProfileRow(id: "sources", title: "Sources", value: "Model + forecast"),
            Phase3ProfileRow(id: "disclaimer", title: "Disclaimer", value: "Non-medical"),
            Phase3ProfileRow(id: "version", title: "Version", value: "v0.3-phase3")
        ]
    )

    static let onboarding: [Phase3OnboardingStep] = [
        Phase3OnboardingStep(
            id: "intro",
            icon: "leaf.circle.fill",
            title: "Check the air before you leave",
            body: "先给出一个结论和一个下一步，让用户立即知道今天该不该担心。"
        ),
        Phase3OnboardingStep(
            id: "location",
            icon: "location.circle.fill",
            title: "Location stays optional",
            body: "即使拒绝定位，也允许手动选城并继续完成主流程。"
        ),
        Phase3OnboardingStep(
            id: "alerts",
            icon: "bell.circle.fill",
            title: "Alerts stay lightweight",
            body: "提醒和权限是增益项，不应该变成强制门槛。"
        )
    ]
}
