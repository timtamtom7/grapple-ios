import SwiftUI
import Speech
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
struct InputView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @State private var isRecording = false
    @FocusState private var isFocused: Bool
    @State private var showModeSelector = false
    @State private var showSourceInput = false
    @State private var showPermissionDenied = false
    @State private var permissionDeniedMessage = ""

    private let speechRecognizer = SFSpeechRecognizer()

    // R10: Usage indicator
    private var usageIndicator: some View {
        let tierManager = GrappleTierManager.shared
        let isLimitReached = tierManager.isLimitReached
        let isPro = tierManager.isPro

        return Group {
            if isLimitReached {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: Theme.Typography.caption2))
                    Text("Monthly limit reached. Upgrade to Pro for unlimited.")
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                    Spacer()
                    Button(action: {
                        Haptics.lightImpact()
                    }) {
                        Text("Upgrade")
                            .font(Theme.Typography.textSemibold(Theme.Typography.caption))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Theme.Colors.success))
                    }
                    .accessibilityLabel("Upgrade to Pro")
                }
                .padding(10)
                .background(Theme.Colors.warning.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.md)
            } else if !isPro {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: Theme.Typography.caption))
                    Text(tierManager.usageDescription)
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Spacer()
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What do you want to test?")
                            .font(Theme.Typography.displaySemibold(Theme.Typography.heading1))
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text("Paste a thought, belief, plan, or writing — Grapple will find the strongest challenges.")
                            .font(Theme.Typography.text(Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(4)

                        // Usage indicator (R10)
                        usageIndicator
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.xxl)

                    // Debate Mode Selector
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Button(action: {
                            Haptics.toggle()
                            showModeSelector.toggle()
                        }) {
                            HStack {
                                Image(systemName: viewModel.debateMode.icon)
                                    .font(.system(size: Theme.Typography.caption2))
                                Text(viewModel.debateMode.rawValue)
                                    .font(Theme.Typography.textMedium(Theme.Typography.bodySmall))
                                Text("·")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                Text(viewModel.debateMode.description)
                                    .font(Theme.Typography.text(Theme.Typography.caption2))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: Theme.Typography.caption2, weight: .semibold))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            .foregroundColor(Theme.Colors.primary)
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.surface)
                            .cornerRadius(Theme.CornerRadius.md)
                        }
                        .accessibilityLabel("Debate mode selector: \(viewModel.debateMode.rawValue)")
                        .accessibilityHint("Double-tap to change debate mode")
                        .padding(.horizontal, Theme.Spacing.lg)

                        if showModeSelector {
                            VStack(spacing: 4) {
                                ForEach(DebateMode.allCases, id: \.self) { mode in
                                    Button(action: {
                                        Haptics.selectionChanged()
                                        viewModel.debateMode = mode
                                        showModeSelector = false
                                    }) {
                                        HStack {
                                            Image(systemName: mode.icon)
                                                .font(.system(size: Theme.Typography.bodySmall))
                                                .frame(width: 20)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(mode.rawValue)
                                                    .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                                                Text(mode.description)
                                                    .font(Theme.Typography.text(Theme.Typography.caption))
                                                    .foregroundColor(Theme.Colors.textSecondary)
                                            }
                                            Spacer()
                                            if viewModel.debateMode == mode {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: Theme.Typography.caption2, weight: .bold))
                                                    .foregroundColor(Theme.Colors.primary)
                                            }
                                        }
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .padding(.horizontal, Theme.Spacing.md)
                                        .padding(.vertical, Theme.Spacing.md)
                                        .background(viewModel.debateMode == mode ? Theme.Colors.surfaceElevated : Color.clear)
                                        .cornerRadius(Theme.CornerRadius.sm)
                                    }
                                }
                            }
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.surface)
                            .cornerRadius(Theme.CornerRadius.md)
                            .padding(.horizontal, Theme.Spacing.lg)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    // Source Input Toggle
                    Button(action: {
                        Haptics.toggle()
                        showSourceInput.toggle()
                    }) {
                        HStack {
                            Image(systemName: "link")
                                .font(.system(size: Theme.Typography.bodySmall))
                            Text(viewModel.sourceURLs.isEmpty ? "Add sources" : "\(viewModel.sourceURLs.count) source(s) added")
                                .font(Theme.Typography.textMedium(Theme.Typography.bodySmall))
                            Spacer()
                            Image(systemName: showSourceInput ? "chevron.up" : "chevron.down")
                                .font(.system(size: Theme.Typography.caption2, weight: .semibold))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .foregroundColor(viewModel.sourceURLs.isEmpty ? Theme.Colors.textSecondary : Theme.Colors.success)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                    .accessibilityLabel(viewModel.sourceURLs.isEmpty ? "Add sources" : "\(viewModel.sourceURLs.count) sources added")
                    .accessibilityHint("Double-tap to add or remove sources")
                    .padding(.horizontal, Theme.Spacing.lg)

                    if showSourceInput {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            HStack {
                                TextField("Paste URL here...", text: $viewModel.sourceInputText)
                                    .font(Theme.Typography.text(Theme.Typography.body))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()

                                Button(action: {
                                    Haptics.lightImpact()
                                    addSource()
                                }) {
                                    Text("Add")
                                        .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Theme.Colors.primary)
                                        .cornerRadius(Theme.CornerRadius.sm)
                                }
                                .disabled(viewModel.sourceInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .accessibilityLabel("Add URL")
                            }
                            .padding(Theme.Spacing.md)
                            .background(Theme.Colors.surfaceElevated)
                            .cornerRadius(Theme.CornerRadius.md)

                            ForEach(viewModel.sourceURLs, id: \.self) { url in
                                HStack {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(Theme.Colors.success)
                                    Text(url)
                                        .font(Theme.Typography.mono(Theme.Typography.caption))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .lineLimit(1)
                                    Spacer()
                                    Button(action: {
                                        Haptics.lightImpact()
                                        viewModel.sourceURLs.removeAll { $0 == url }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Theme.Colors.danger)
                                    }
                                    .accessibilityLabel("Remove source \(url)")
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Input area
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                            .fill(Theme.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                    .stroke(isFocused ? Theme.Colors.primary : Theme.Colors.divider, lineWidth: 1)
                            )

                        TextEditor(text: $viewModel.inputText)
                            .font(Theme.Typography.text(Theme.Typography.bodyLarge))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .padding(Theme.Spacing.lg)
                            .focused($isFocused)

                        if viewModel.inputText.isEmpty {
                            Text("What's on your mind? Paste a thought, belief, plan, or piece of writing you want to test...")
                                .font(Theme.Typography.text(Theme.Typography.bodyLarge))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(minHeight: 200)
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Character count & voice button row
                    HStack {
                        Text("\(viewModel.inputText.count) characters")
                            .font(Theme.Typography.text(Theme.Typography.caption2))
                            .foregroundColor(viewModel.inputText.count >= 20 ? Theme.Colors.success : Theme.Colors.textSecondary)

                        Spacer()

                        Button(action: {
                            Haptics.lightImpact()
                            toggleRecording()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                Text(isRecording ? "Recording..." : "Voice")
                            }
                            .font(Theme.Typography.textMedium(Theme.Typography.bodySmall))
                            .foregroundColor(isRecording ? Theme.Colors.danger : Theme.Colors.textSecondary)
                        }
                        .disabled(isRecording)
                        .accessibilityLabel(isRecording ? "Stop recording" : "Start voice recording")
                    }
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Mode badge
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.debateMode.icon)
                            .font(.system(size: Theme.Typography.caption))
                        Text("\(viewModel.debateMode.argumentCount) arguments · \(viewModel.debateMode.hasRebuttal ? "With rebuttals" : "Quick mode")")
                            .font(Theme.Typography.text(Theme.Typography.caption2))
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Tip
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Tip")
                            .font(Theme.Typography.textSemibold(Theme.Typography.caption2))
                            .foregroundColor(Theme.Colors.textSecondary)

                        Text("The more specific your thought, the sharper Grapple's challenges will be.")
                            .font(Theme.Typography.text(Theme.Typography.caption2))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.md)
                    .padding(.horizontal, Theme.Spacing.lg)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.divider)

                Button(action: {
                    Haptics.grappleStart()
                    Task {
                        await viewModel.startGrapple()
                    }
                }) {
                    HStack {
                        Text(viewModel.debateMode == .quick ? "Start Quick Grapple" : "Start Grapple")
                            .font(Theme.Typography.textSemibold(Theme.Typography.button))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                            .fill(viewModel.canStartGrapple ? Theme.Colors.primary : Theme.Colors.disabled)
                    )
                }
                .disabled(!viewModel.canStartGrapple)
                .accessibilityLabel(viewModel.canStartGrapple ? "Start Grapple" : "Start Grapple (minimum 20 characters required)")
                .accessibilityHint("Double-tap to begin the grapple session")
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
        }
        .animation(.easeOut(duration: Theme.Animation.snappy), value: showModeSelector)
        .animation(.easeOut(duration: Theme.Animation.snappy), value: showSourceInput)
        .alert("Voice Input Unavailable", isPresented: $showPermissionDenied) {
            Button("Open Settings", role: .none) {
                #if canImport(UIKit)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #endif
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(permissionDeniedMessage)
        }
    }

    private func addSource() {
        let trimmed = viewModel.sourceInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, URL(string: trimmed) != nil else { return }
        if !viewModel.sourceURLs.contains(trimmed) {
            viewModel.sourceURLs.append(trimmed)
        }
        viewModel.sourceInputText = ""
    }

    private func toggleRecording() {
        if isRecording {
            isRecording = false
            return
        }

        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    #if canImport(AVFoundation) && !os(macOS)
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            if granted {
                                isRecording = true
                            } else {
                                permissionDeniedMessage = "Microphone access was denied."
                                showPermissionDenied = true
                            }
                        }
                    }
                    #else
                    isRecording = true
                    #endif
                case .denied, .restricted:
                    permissionDeniedMessage = "Speech recognition is not available."
                    showPermissionDenied = true
                case .notDetermined:
                    permissionDeniedMessage = "Speech recognition permission hasn't been requested yet."
                    showPermissionDenied = true
                @unknown default:
                    permissionDeniedMessage = "An unexpected permission issue occurred."
                    showPermissionDenied = true
                }
            }
        }
    }
}
#endif
