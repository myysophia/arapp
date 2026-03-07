import Foundation

enum L10n {
    private static let localeDefaultsKey = "arapp.locale.identifier"

    static var storedLocaleIdentifier: String {
        UserDefaults.standard.string(forKey: localeDefaultsKey)
            ?? (Locale.preferredLanguages.first?.hasPrefix("en") == true ? "en" : "zh-Hans")
    }

    static var apiLanguageIdentifier: String {
        storedLocaleIdentifier.hasPrefix("en") ? "en" : "zh-Hans"
    }

    static func setLocaleIdentifier(_ identifier: String) {
        UserDefaults.standard.set(identifier, forKey: localeDefaultsKey)
    }

    static func tr(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: localizedBundle, value: key, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: tr(key), locale: .autoupdatingCurrent, arguments: arguments)
    }

    private static var localizedBundle: Bundle {
        guard
            let path = Bundle.main.path(forResource: storedLocaleIdentifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }
}
