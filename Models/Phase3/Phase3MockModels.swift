import Foundation
import SwiftUI

enum Phase3FlowState: String, CaseIterable, Identifiable, Sendable {
    case onboarding
    case login
    case main

    var id: String { rawValue }
}

enum Phase3LoginState: String, CaseIterable, Identifiable, Sendable {
    case idle
    case loadingGoogle
    case loadingGitHub
    case loadingApple
    case failed

    var id: String { rawValue }
}

enum Phase3TodayState: String, CaseIterable, Identifiable, Sendable {
    case loading
    case success
    case stale
    case error
    case empty
    case offline

    var id: String { rawValue }
}

enum Phase3MapState: String, CaseIterable, Identifiable, Sendable {
    case coverage
    case selected
    case searchSheet
    case sourceSheet
    case noLocation
    case offline

    var id: String { rawValue }
}

enum Phase3AlertsState: String, CaseIterable, Identifiable, Sendable {
    case saved
    case anonymous
    case notificationsOff
    case empty
    case error

    var id: String { rawValue }
}

enum Phase3ProfileState: String, CaseIterable, Identifiable, Sendable {
    case anonymous
    case signedIn
    case deleteConfirm

    var id: String { rawValue }
}

enum Phase3OnboardingState: String, CaseIterable, Identifiable, Sendable {
    case baseline
    case locationDenied
    case notificationSkipped

    var id: String { rawValue }
}

struct Phase3LoginModel: Sendable {
    let title: String
    let subtitle: String
    let anonymousTitle: String
    let anonymousSubtitle: String
    let errorMessage: String
}

struct Phase3TodayModel: Sendable {
    let cityName: String
    let riskTitle: String
    let riskDescription: String
    let riskLevel: AppRiskLevel
    let badgeText: String
    let metrics: [RiskHeroMetric]
    let breakdownItems: [PollenBreakdownItem]
    let trendItems: [TrendMiniChartItem]
    let adviceItems: [Phase3AdviceItem]
    let sourceProviderName: String
    let sourceTypeLabel: String
    let coverageNote: String
    let licenseNote: String
    let updatedAtText: String
    let disclaimer: String
}

struct Phase3AdviceItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
}

struct Phase3MapModel: Sendable {
    let selectedCity: String
    let pointName: String
    let pointSummary: String
    let providerLabel: String
    let sourceDescription: String
    let updatedAt: String
    let confidence: String
}

struct Phase3AlertsHistoryItem: Identifiable, Hashable, Sendable {
    let id: String
    let time: String
    let level: AppRiskLevel
}

struct Phase3AlertsModel: Sendable {
    let cityName: String
    let summary: String
    let quietHours: String
    let threshold: Double
    let history: [Phase3AlertsHistoryItem]
}

struct Phase3ProfileRow: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let value: String
}

struct Phase3ProfileModel: Sendable {
    let anonymousSummary: String
    let signedInSummary: String
    let providersText: String
    let preferences: [Phase3ProfileRow]
    let privacy: [Phase3ProfileRow]
    let about: [Phase3ProfileRow]
}

struct Phase3OnboardingStep: Identifiable, Hashable, Sendable {
    let id: String
    let icon: String
    let title: String
    let body: String
}
