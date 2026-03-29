import SwiftUI

enum MacTheme {
    static let background = Color(hex: "0F1419")
    static let surface = Color(hex: "1A2332")
    static let elevated = Color(hex: "243044")
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "8B9BB4")
    static let challenge = Color(hex: "E63946")
    static let rebuttal = Color(hex: "4A90D9")
    static let success = Color(hex: "52B788")
    static let gold = Color(hex: "D4AF37")
    static let divider = Color(hex: "2D3F54")

    static let cornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 32
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
