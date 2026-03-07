import SwiftUI

enum AppRiskLevel: Int, CaseIterable, Codable, Sendable {
    case none = 0
    case veryLow = 1
    case low = 2
    case moderate = 3
    case high = 4
    case veryHigh = 5
}

enum RiskPalette {
    static func color(for level: AppRiskLevel) -> Color {
        switch level {
        case .none:
            Color(hex: 0xCBD5E1)
        case .veryLow:
            Color(hex: 0x86EFAC)
        case .low:
            Color(hex: 0x4ADE80)
        case .moderate:
            Color(hex: 0xFACC15)
        case .high:
            Color(hex: 0xFB923C)
        case .veryHigh:
            Color(hex: 0xEF4444)
        }
    }

    static func labelColor(for level: AppRiskLevel) -> Color {
        switch level {
        case .none:
            AppColor.textSecondary
        case .veryLow, .low:
            AppColor.brandDeep
        case .moderate:
            Color(hex: 0x7C5D00)
        case .high, .veryHigh:
            .white
        }
    }
}

extension AppRiskLevel {
    var displayText: String {
        switch self {
        case .none:
            "极低"
        case .veryLow:
            "很低"
        case .low:
            "较低"
        case .moderate:
            "中等"
        case .high:
            "较高"
        case .veryHigh:
            "极高"
        }
    }

    var progress: CGFloat {
        CGFloat(rawValue) / CGFloat(AppRiskLevel.veryHigh.rawValue)
    }
}
