import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Haptics Utility

/// Centralized haptic feedback utility for Grapple.
/// Use these methods instead of calling UIImpactFeedbackGenerator directly.
@MainActor
enum Haptics {

    // MARK: - Impact Feedback

    /// Light impact — for subtle UI interactions (toggles, selections)
    static func lightImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// Medium impact — for button presses, card interactions
    static func mediumImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// Heavy impact — for significant actions (submit, complete)
    static func heavyImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// Soft impact — for iOS 26 liquid glass gentle feedback
    static func softImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// Rigid impact — for iOS 26 liquid glass crisp feedback
    static func rigidImpact() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    // MARK: - Selection Feedback

    /// Selection changed — for tab switches, picker changes
    static func selectionChanged() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }

    // MARK: - Notification Feedback

    /// Success notification — for completed actions
    static func success() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Warning notification — for caution states
    static func warning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        #endif
    }

    /// Error notification — for failed actions
    static func error() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        #endif
    }

    // MARK: - Semantic Haptics

    /// Card tap — light impact for argument card expansion
    static func cardTap() {
        lightImpact()
    }

    /// Button tap — medium impact for primary button presses
    static func buttonTap() {
        mediumImpact()
    }

    /// Submit action — heavy impact + success for form submissions
    static func submit() {
        heavyImpact()
        success()
    }

    /// Tab switch — selection changed
    static func tabSwitch() {
        selectionChanged()
    }

    /// Toggle — soft impact
    static func toggle() {
        softImpact()
    }

    /// Expand/collapse — selection feedback
    static func expand() {
        selectionChanged()
    }

    /// Delete action — warning feedback
    static func delete() {
        warning()
    }

    /// Synthesis complete — heavy success
    static func synthesisComplete() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            success()
        }
    }

    /// Grapple start — rigid impact
    static func grappleStart() {
        rigidImpact()
    }

    /// Rebuttal judgment received — light success
    static func judgmentReceived() {
        lightImpact()
    }
}

// MARK: - View Modifier for Haptic Buttons

/// A button style that includes haptic feedback on press.
struct HapticButtonStyle<Label: View>: View {
    let action: () -> Void
    let label: () -> Label
    let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle

    init(
        impactStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.impactStyle = impactStyle
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            let generator = UIImpactFeedbackGenerator(style: impactStyle)
            generator.prepare()
            generator.impactOccurred()
            #endif
            action()
        }) {
            label()
        }
    }
}

// MARK: - Haptic Tap Gesture

/// Adds haptic feedback to any tap gesture.
struct HapticTapGesture: ViewModifier {
    let impactStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                #if canImport(UIKit)
                let generator = UIImpactFeedbackGenerator(style: impactStyle)
                generator.prepare()
                generator.impactOccurred()
                #endif
                action()
            }
    }
}

extension View {
    func hapticTap(
        style: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(HapticTapGesture(impactStyle: style, action: action))
    }
}
