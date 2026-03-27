import SwiftUI

// MARK: - iOS 26 Liquid Glass Design System for Grapple

/// Centralized design tokens for iOS 26 Liquid Glass aesthetic.
/// Use these tokens throughout the app for consistent styling.
enum Theme {

    // MARK: - Corner Radius Tokens

    /// Corner radius tokens following iOS 26 Liquid Glass guidelines.
    /// All radii are defined as tokens to ensure consistency.
    enum CornerRadius {
        /// 4pt — tiny elements, badges
        static let xs: CGFloat = 4
        /// 6pt — small chips, tags
        static let sm: CGFloat = 6
        /// 8pt — cards, inputs, list items
        static let md: CGFloat = 8
        /// 12pt — buttons, modals, large cards
        static let lg: CGFloat = 12
        /// 16pt — sheets, large containers
        static let xl: CGFloat = 16
        /// 20pt — bottom sheets, large panels
        static let xxl: CGFloat = 20
        /// 24pt — full-width liquid glass panels
        static let xxxl: CGFloat = 24
        /// 28pt — maximum radius for iOS 26 liquid glass
        static let max: CGFloat = 28
    }

    // MARK: - Color Palette

    /// Grapple color palette — Academic debate court aesthetic.
    enum Colors {
        /// Background — Dark Slate `#0F1419`
        static let background = Color(hex: "0F1419")
        /// Surface — Slate Gray `#1A2332`
        static let surface = Color(hex: "1A2332")
        /// Surface Elevated — Lighter Slate `#243044`
        static let surfaceElevated = Color(hex: "243044")
        /// Primary Text — White `#FFFFFF`
        static let textPrimary = Color.white
        /// Secondary Text — Cool Gray `#8B9BB4`
        static let textSecondary = Color(hex: "8B9BB4")
        /// Tertiary Text — `#6B7280`
        static let textTertiary = Color(hex: "6B7280")
        /// Challenge / Danger — Deep Red `#E63946`
        static let danger = Color(hex: "E63946")
        /// Rebuttal / Trust — Steel Blue `#4A90D9`
        static let primary = Color(hex: "4A90D9")
        /// Success / Synthesis — Muted Green `#52B788`
        static let success = Color(hex: "52B788")
        /// Warning / Amber — `#F4A261`
        static let warning = Color(hex: "F4A261")
        /// Divider — Slate Border `#2D3F54`
        static let divider = Color(hex: "2D3F54")
        /// Disabled surface — `#1A2332` with 50% opacity
        static let disabled = Color(hex: "243044")
        /// Glass fill — subtle glass overlay
        static let glassFill = Color.white.opacity(0.04)
        /// Glass border — subtle glass border
        static let glassBorder = Color.white.opacity(0.08)
    }

    // MARK: - Typography Scale

    /// Typography scale ensuring minimum 11pt for accessibility.
    /// All sizes are explicitly defined to prevent accidental below-11pt values.
    enum Typography {
        /// 11pt — captions, badges, labels (MINIMUM)
        static let caption: CGFloat = 11
        /// 12pt — secondary labels, hints
        static let caption2: CGFloat = 12
        /// 13pt — body small, buttons
        static let bodySmall: CGFloat = 13
        /// 14pt — body default, descriptions
        static let body: CGFloat = 14
        /// 15pt — arguments, monospaced body
        static let bodyMono: CGFloat = 15
        /// 16pt — inputs, large body
        static let bodyLarge: CGFloat = 16
        /// 17pt — CTA buttons (iOS standard minimum touch target)
        static let button: CGFloat = 17
        /// 18pt — section titles
        static let sectionTitle: CGFloat = 18
        /// 20pt — headings
        static let heading3: CGFloat = 20
        /// 24pt — large headings
        static let heading2: CGFloat = 24
        /// 28pt — titles
        static let heading1: CGFloat = 28

        // MARK: - Font Helpers

        /// Returns a SF Pro Display font at the specified size with semibold weight.
        static func displaySemibold(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .semibold, design: .default)
        }

        /// Returns a SF Pro Display font at the specified size with bold weight.
        static func displayBold(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .bold, design: .default)
        }

        /// Returns a SF Pro Text font at the specified size with regular weight.
        static func text(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .regular, design: .default)
        }

        /// Returns a SF Pro Text font at the specified size with medium weight.
        static func textMedium(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .medium, design: .default)
        }

        /// Returns a SF Pro Text font at the specified size with semibold weight.
        static func textSemibold(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .semibold, design: .default)
        }

        /// Returns a SF Mono font at the specified size (minimum 11pt).
        static func mono(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), design: .monospaced)
        }

        /// Returns a SF Mono font at the specified size with semibold weight.
        static func monoSemibold(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .semibold, design: .monospaced)
        }

        /// Returns a SF Mono font at the specified size with bold weight.
        static func monoBold(_ size: CGFloat) -> Font {
            .system(size: max(size, 11), weight: .bold, design: .monospaced)
        }
    }

    // MARK: - Spacing

    /// Spacing scale based on 8pt grid.
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        static let huge: CGFloat = 40
    }

    // MARK: - Shadows (Liquid Glass)

    /// Liquid Glass shadow definitions for iOS 26.
    /// These simulate the depth of glass-morphism elements.
    enum Shadow {
        /// Subtle shadow for cards — 4pt blur, 2pt y-offset
        static let card = (
            color: Color.black.opacity(0.3),
            radius: CGFloat(4),
            x: CGFloat(0),
            y: CGFloat(2)
        )
        /// Medium shadow for elevated cards — 8pt blur, 4pt y-offset
        static let cardElevated = (
            color: Color.black.opacity(0.4),
            radius: CGFloat(8),
            x: CGFloat(0),
            y: CGFloat(4)
        )
        /// Strong shadow for modals/sheets — 16pt blur, 8pt y-offset
        static let modal = (
            color: Color.black.opacity(0.5),
            radius: CGFloat(16),
            x: CGFloat(0),
            y: CGFloat(8)
        )
        /// Glow shadow for primary buttons — colored glow
        static let primaryGlow = (
            color: Color(hex: "4A90D9").opacity(0.4),
            radius: CGFloat(12),
            x: CGFloat(0),
            y: CGFloat(4)
        )
    }

    // MARK: - Animation Durations

    enum Animation {
        /// Instant — for toggles and immediate feedback
        static let instant: Double = 0.1
        /// Snappy — for small UI changes (button press)
        static let snappy: Double = 0.2
        /// Standard — for card transitions
        static let standard: Double = 0.3
        /// Smooth — for page transitions and reveals
        static let smooth: Double = 0.4
        /// Dramatic — for synthesis reveals
        static let dramatic: Double = 0.5
    }

    // MARK: - Touch Targets

    /// iOS minimum touch target is 44pt. Use these for buttons.
    enum TouchTarget {
        static let minimum: CGFloat = 44
        static let comfortable: CGFloat = 50
    }
}

// MARK: - Liquid Glass Button Styles

/// Primary action button — filled with primary color.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.textSemibold(Theme.Typography.button))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .fill(isEnabled ? Theme.Colors.primary : Theme.Colors.disabled)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: Theme.Animation.instant), value: configuration.isPressed)
    }
}

/// Secondary button — outlined style.
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.textSemibold(Theme.Typography.button))
            .foregroundColor(isEnabled ? Theme.Colors.primary : Theme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(isEnabled ? Theme.Colors.primary : Theme.Colors.divider, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: Theme.Animation.instant), value: configuration.isPressed)
    }
}

/// Ghost button — transparent with text color.
struct GhostButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.textMedium(Theme.Typography.body))
            .foregroundColor(isEnabled ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            .padding(.vertical, Theme.Spacing.md)
            .padding(.horizontal, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(configuration.isPressed ? Theme.Colors.glassFill : Color.clear)
            )
            .animation(.easeInOut(duration: Theme.Animation.instant), value: configuration.isPressed)
    }
}

/// Danger button — filled with danger color.
struct DangerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.textSemibold(Theme.Typography.button))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .fill(isEnabled ? Theme.Colors.danger : Theme.Colors.disabled)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: Theme.Animation.instant), value: configuration.isPressed)
    }
}

/// Success button — filled with success color.
struct SuccessButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.textSemibold(Theme.Typography.button))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .fill(isEnabled ? Theme.Colors.success : Theme.Colors.disabled)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: Theme.Animation.instant), value: configuration.isPressed)
    }
}

// MARK: - Card Modifier

/// Applies liquid glass card styling.
struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.CornerRadius.md
    var borderColor: Color = Theme.Colors.divider

    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = Theme.CornerRadius.md,
        borderColor: Color = Theme.Colors.divider
    ) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}

// MARK: - Accessibility Helpers

/// Generates a meaningful accessibility label from an argument card.
func argumentAccessibilityLabel(type: String, severity: Int, confidence: String) -> String {
    "A \(confidence) confidence \(type) argument with severity \(severity) out of 3."
}

/// Generates accessibility label for a rebuttal field.
func rebuttalAccessibilityLabel(type: String, judgment: String?, isEmpty: Bool) -> String {
    if isEmpty {
        return "Rebuttal field for \(type) argument. Empty."
    } else if let judgment = judgment {
        return "Rebuttal field for \(type) argument. Judgment: \(judgment)."
    }
    return "Rebuttal field for \(type) argument."
}

/// Generates accessibility label for a session row.
func sessionRowAccessibilityLabel(topic: String, outcome: String, argumentCount: Int) -> String {
    "Session about \(topic). Outcome: \(outcome). Contains \(argumentCount) arguments."
}
