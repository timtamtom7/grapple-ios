import SwiftUI

struct MacGrappleFlowView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419")
                    .ignoresSafeArea()

                switch viewModel.phase {
                case .input:
                    MacInputView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .leading)))

                case .grappling, .judgingRebuttals, .synthesizing:
                    MacLoadingView(message: viewModel.loadingMessage)
                        .transition(.opacity)

                case .arguments:
                    MacArgumentsView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))

                case .rebuttal:
                    MacRebuttalView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))

                case .quickComplete, .complete:
                    MacSynthesisView(viewModel: viewModel, historyViewModel: historyViewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.phase)
        }
        .alert("Something went wrong", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected error occurred.")
        }
    }
}

// MARK: - Mac Input View

struct MacInputView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your thought?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Grapple will challenge it from multiple angles.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // Submit button
                Button(action: {
                    Task { await viewModel.startGrapple() }
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("Start Grappling")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "4A90D9")))
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .background(Color(hex: "0F1419"))
    }
}

// MARK: - Mac Loading View

struct MacLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(Color(hex: "4A90D9"))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Mac Arguments View (simplified)

struct MacArgumentsView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: viewModel.debateMode.icon)
                        .foregroundColor(Color(hex: "4A90D9"))
                    Text(viewModel.debateMode.rawValue)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "4A90D9"))
                    Spacer()
                    Text("\(viewModel.counterArguments.count) arguments")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
                .padding(.horizontal, 20)

                ForEach(viewModel.counterArguments) { arg in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(arg.type.icon)
                                .font(.system(size: 12))
                            Text(arg.type.rawValue)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: arg.confidenceLevel.color))
                            Spacer()
                        }
                        Text(arg.text)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                }

                Button(action: { viewModel.proceedToRebuttal() }) {
                    Text("Respond to All")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "4A90D9")))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.vertical, 16)
        }
        .background(Color(hex: "0F1419"))
    }
}

// MARK: - Mac Rebuttal View (simplified)

struct MacRebuttalView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Responses")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)

                ForEach(viewModel.counterArguments.indices, id: \.self) { index in
                    let arg = viewModel.counterArguments[index]
                    VStack(alignment: .leading, spacing: 8) {
                        Text(arg.type.icon + " " + arg.type.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: arg.confidenceLevel.color))
                        Text(arg.text)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineLimit(3)

                        Divider().background(Color(hex: "2D3F54"))

                        TextEditor(text: Binding(
                            get: { viewModel.rebuttals[index].text },
                            set: { viewModel.rebuttals[index].text = $0 }
                        ))
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color(hex: "1A2332"))
                        .frame(minHeight: 60)
                        .cornerRadius(6)
                    }
                    .padding(14)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                }

                Button(action: {
                    Task { await viewModel.submitRebuttals() }
                }) {
                    Text("View Synthesis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "52B788")))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.vertical, 16)
        }
        .background(Color(hex: "0F1419"))
    }
}

// MARK: - Mac Synthesis View (simplified)

struct MacSynthesisView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel

    var body: some View {
        ScrollView {
            if let synth = viewModel.synthesis {
                VStack(alignment: .leading, spacing: 24) {
                    // Verdict
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Final Verdict")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: "52B788"))
                        Text(synth.verdict)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)

                    // What Survived
                    sectionView(title: "What Survived", text: synth.whatSurvived, color: "52B788")

                    // What Collapsed
                    sectionView(title: "What Collapsed", text: synth.whatCollapsed, color: "E63946")

                    // Needs Evidence
                    sectionView(title: "Needs Evidence", text: synth.needsEvidence, color: "F4A261")
                }
                .padding(.vertical, 20)
            } else {
                Text("No synthesis available.")
                    .foregroundColor(Color(hex: "8B9BB4"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(hex: "0F1419"))
    }

    @ViewBuilder
    private func sectionView(title: String, text: String, color: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: color))
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A2332"))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

// MARK: - Mac History View

struct MacHistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        Group {
            if viewModel.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "4A90D9").opacity(0.4))
                    Text("No sessions yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.sessions) { session in
                    MacSessionRow(session: session)
                }
                .listStyle(.plain)
            }
        }
        .background(Color(hex: "0F1419"))
        .navigationTitle("History")
    }
}

struct MacSessionRow: View {
    let session: GrappleSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.topic)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            HStack {
                Text(session.debateMode.rawValue)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(hex: "4A90D9"))
                Text("·")
                    .foregroundColor(Color(hex: "8B9BB4"))
                Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8B9BB4"))
            }
        }
        .padding(.vertical, 4)
    }
}
