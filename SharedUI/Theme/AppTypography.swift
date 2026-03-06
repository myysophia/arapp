import SwiftUI

enum AppTypography {
    static var titleHero: Font {
        .system(size: 28, weight: .semibold)
    }

    static var titleSection: Font {
        .system(size: 22, weight: .semibold)
    }

    static var titleCard: Font {
        .system(size: 17, weight: .semibold)
    }

    static var body: Font {
        .system(size: 15, weight: .regular)
    }

    static var bodyStrong: Font {
        .system(size: 15, weight: .medium)
    }

    static var caption: Font {
        .system(size: 13, weight: .regular)
    }

    static var captionStrong: Font {
        .system(size: 13, weight: .medium)
    }

    static var numberLarge: Font {
        .system(size: 28, weight: .semibold, design: .rounded)
    }

    static var numberBody: Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }
}
