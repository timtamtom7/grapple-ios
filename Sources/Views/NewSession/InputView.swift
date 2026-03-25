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
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F4A261"))
                    Text("Monthly limit reached. Upgrade to Pro for unlimited.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F4A261"))
                    Spacer()
                    Button(action: {}) {
                        Text("Upgrade")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color(hex: "52B788")))
                    }
                }
                .padding(10)
                .background(Color(hex: "F4A261").opacity(0.1))
                .cornerRadius(8)
            } else if !isPro {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "4A90D9"))
                    Text(tierManager.usageDescription)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
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
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Paste a thought, belief, plan, or writing — Grapple will find the strongest challenges.")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineSpacing(4)

                        // Usage indicator (R10)
                        usageIndicator
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Debate Mode Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: { showModeSelector.toggle() }) {
                            HStack {
                                Image(systemName: viewModel.debateMode.icon)
                                    .font(.system(size: 14))
                                Text(viewModel.debateMode.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                Text("·")
                                    .foregroundColor(Color(hex: "8B9BB4"))
                                Text(viewModel.debateMode.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "8B9BB4"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "8B9BB4"))
                            }
                            .foregroundColor(Color(hex: "4A90D9"))
                            .padding(12)
                            .background(Color(hex: "1A2332"))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 16)

                        if showModeSelector {
                            VStack(spacing: 4) {
                                ForEach(DebateMode.allCases, id: \.self) { mode in
                                    Button(action: {
                                        viewModel.debateMode = mode
                                        showModeSelector = false
                                    }) {
                                        HStack {
                                            Image(systemName: mode.icon)
                                                .font(.system(size: 13))
                                                .frame(width: 20)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(mode.rawValue)
                                                    .font(.system(size: 13, weight: .semibold))
                                                Text(mode.description)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color(hex: "8B9BB4"))
                                            }
                                            Spacer()
                                            if viewModel.debateMode == mode {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(Color(hex: "4A90D9"))
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(viewModel.debateMode == mode ? Color(hex: "243044") : Color.clear)
                                        .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(hex: "1A2332"))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    // Source Input Toggle
                    Button(action: { showSourceInput.toggle() }) {
                        HStack {
                            Image(systemName: "link")
                                .font(.system(size: 13))
                            Text(viewModel.sourceURLs.isEmpty ? "Add sources" : "\(viewModel.sourceURLs.count) source(s) added")
                                .font(.system(size: 13, weight: .medium))
                            Spacer()
                            Image(systemName: showSourceInput ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(hex: "8B9BB4"))
                        }
                        .foregroundColor(viewModel.sourceURLs.isEmpty ? Color(hex: "8B9BB4") : Color(hex: "52B788"))
                        .padding(12)
                        .background(Color(hex: "1A2332"))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)

                    if showSourceInput {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                TextField("Paste URL here...", text: $viewModel.sourceInputText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()

                                Button(action: addSource) {
                                    Text("Add")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "4A90D9"))
                                        .cornerRadius(6)
                                }
                                .disabled(viewModel.sourceInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(12)
                            .background(Color(hex: "243044"))
                            .cornerRadius(8)

                            ForEach(viewModel.sourceURLs, id: \.self) { url in
                                HStack {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(Color(hex: "52B788"))
                                    Text(url)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(Color(hex: "8B9BB4"))
                                        .lineLimit(1)
                                    Spacer()
                                    Button(action: { viewModel.sourceURLs.removeAll { $0 == url } }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color(hex: "E63946"))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Input area
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "1A2332"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isFocused ? Color(hex: "4A90D9") : Color(hex: "2D3F54"), lineWidth: 1)
                            )

                        TextEditor(text: $viewModel.inputText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(16)
                            .focused($isFocused)

                        if viewModel.inputText.isEmpty {
                            Text("What's on your mind? Paste a thought, belief, plan, or piece of writing you want to test...")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "8B9BB4"))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(minHeight: 200)
                    .padding(.horizontal, 16)

                    // Character count & voice button row
                    HStack {
                        Text("\(viewModel.inputText.count) characters")
                            .font(.system(size: 12))
                            .foregroundColor(viewModel.inputText.count >= 20 ? Color(hex: "52B788") : Color(hex: "8B9BB4"))

                        Spacer()

                        Button(action: toggleRecording) {
                            HStack(spacing: 6) {
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                Text(isRecording ? "Recording..." : "Voice")
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isRecording ? Color(hex: "E63946") : Color(hex: "8B9BB4"))
                        }
                        .disabled(isRecording)
                    }
                    .padding(.horizontal, 16)

                    // Mode badge
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.debateMode.icon)
                            .font(.system(size: 11))
                        Text("\(viewModel.debateMode.argumentCount) arguments · \(viewModel.debateMode.hasRebuttal ? "With rebuttals" : "Quick mode")")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "8B9BB4"))
                    .padding(.horizontal, 16)

                    // Tip
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tip")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        Text("The more specific your thought, the sharper Grapple's challenges will be.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineSpacing(3)
                    }
                    .padding(12)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "2D3F54"))

                Button(action: {
                    Task {
                        await viewModel.startGrapple()
                    }
                }) {
                    HStack {
                        Text(viewModel.debateMode == .quick ? "Start Quick Grapple" : "Start Grapple")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canStartGrapple ? Color(hex: "4A90D9") : Color(hex: "243044"))
                    )
                }
                .disabled(!viewModel.canStartGrapple)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
        .animation(.easeOut(duration: 0.2), value: showModeSelector)
        .animation(.easeOut(duration: 0.2), value: showSourceInput)
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
