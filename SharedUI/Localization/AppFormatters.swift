import Foundation

enum AppFormatters {
    static func shortDateTime(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .numeric, time: .shortened)
                .locale(.autoupdatingCurrent)
        )
    }

    static func monthDayText(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle()
                .month(.twoDigits)
                .day(.twoDigits)
                .locale(.autoupdatingCurrent)
        )
    }

    static func relativeText(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }

    static func isoDateTimeText(_ rawValue: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: rawValue) else {
            return rawValue
        }
        return shortDateTime(date)
    }

    static func percentText(_ value: Double) -> String {
        "\(Int(value * 100))%"
    }
}
