import Foundation
import SwiftUI

extension PollenRiskLevel {
    var uiLevel: AppRiskLevel {
        AppRiskLevel(rawValue: rawValue) ?? .none
    }
}

extension AppRiskLevel {
    var displayText: String {
        switch self {
        case .none:
            L10n.tr("risk.level.none")
        case .veryLow:
            L10n.tr("risk.level.very_low")
        case .low:
            L10n.tr("risk.level.low")
        case .moderate:
            L10n.tr("risk.level.moderate")
        case .high:
            L10n.tr("risk.level.high")
        case .veryHigh:
            L10n.tr("risk.level.very_high")
        }
    }

    var progress: CGFloat {
        CGFloat(rawValue) / CGFloat(AppRiskLevel.veryHigh.rawValue)
    }
}

extension PollenSourceType {
    var displayText: String {
        switch self {
        case .model:
            L10n.tr("source.type.model")
        case .station:
            L10n.tr("source.type.station")
        case .vendor:
            L10n.tr("source.type.vendor")
        }
    }
}

extension SourceMeta {
    static func placeholder(for source: PollenSourceType) -> SourceMeta {
        SourceMeta(
            id: UUID(),
            providerName: L10n.tr("source.placeholder.provider"),
            source: source,
            coverageNote: L10n.tr("source.placeholder.coverage"),
            licenseNote: L10n.tr("source.placeholder.license"),
            active: true,
            updatedAt: .now
        )
    }
}

extension PollenSummary {
    var updatedAtText: String {
        L10n.format("common.updated_at", updatedAt.relativeText)
    }

    var sourceTag: String {
        source.displayText
    }
}

extension Date {
    var relativeText: String {
        AppFormatters.relativeText(self)
    }
}
