import SwiftUI

/// Accessibility helpers for Grapple
enum AccessibilitySchemes {
    /// Returns nil animation when Reduce Motion is enabled, otherwise the provided animation.
    static func animation(for reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)
    }

    /// Returns a slow spring animation when Reduce Motion is disabled.
    static var defaultSpring: Animation {
        .spring(response: 0.35, dampingFraction: 0.75)
    }
}
