import SwiftUI

struct iPadGrappleView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @State private var selectedArgumentId: UUID?

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left panel: Counter-Arguments
                argumentPanel
                    .frame(width: geometry.size.width * 0.45)

                Divider()
                    .background(Color(hex: "2D3F54"))
                    .frame(width: 1)

                // Right panel: Rebuttal or Synthesis
                rebuttalPanel
                    .frame(width: geometry.size.width * 0.55)
            }
        }
        .background(Color(hex: "0F1419"))
    }

    // MARK: - Argument Panel (Left)

    @ViewBuilder
    private var argumentPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: viewModel.debateMode.icon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "4A90D9"))
                    Text(viewModel.debateMode.rawValue)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "4A90D9"))
                    Spacer()
                    Text("\(viewModel.counterArguments.count) arguments")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }

                Text(viewModel.debateMode == .opposingView ?
                     "AI argues the opposing view. Respond to each challenge." :
                     "Strongest challenges to your thinking. Select to respond.")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "8B9BB4"))
                    .lineSpacing(3)
            }
            .padding(16)
            .background(Color(hex: "0F1419"))

            Divider()
                .background(Color(hex: "2D3F54"))

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.counterArguments) { argument in
                        iPadArgumentRow(
                            argument: argument,
                            isSelected: selectedArgumentId == argument.id,
                            rebuttal: binding(for: argument.id)
                        ) {
                            selectedArgumentId = argument.id
                        }
                    }
                }
                .padding(16)
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "2D3F54"))

                if viewModel.debateMode.hasRebuttal {
                    Button(action: { viewModel.proceedToRebuttal() }) {
                        HStack {
                            Text("Respond to All")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "4A90D9")))
                    }
                } else {
                    Button(action: {
                        Task { await viewModel.submitRebuttals() }
                    }) {
                        HStack {
                            Text("View Synthesis")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "52B788")))
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "0F1419"))
        }
        .background(Color(hex: "0F1419"))
    }

    // MARK: - Rebuttal Panel (Right)

    @ViewBuilder
    private var rebuttalPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "52B788"))
                    Text("Your Response")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "52B788"))

                    Spacer()

                    if !viewModel.rebuttalsEntered.description.isEmpty {
                        Text("\(viewModel.rebuttalsEntered) of \(viewModel.counterArguments.count) entered")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "4A90D9"))
                    }
                }

                if let selectedId = selectedArgumentId,
                   let argument = viewModel.counterArguments.first(where: { $0.id == selectedId }) {
                    Text("Responding to: \(argument.text.prefix(80))...")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B9BB4"))
                        .lineLimit(2)
                } else {
                    Text("Select an argument on the left to write your rebuttal.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8B9BB4"))
                }
            }
            .padding(16)
            .background(Color(hex: "0F1419"))

            Divider()
                .background(Color(hex: "2D3F54"))

            if viewModel.phase == .rebuttal || viewModel.phase == .judgingRebuttals || viewModel.phase == .synthesizing {
                rebuttalContent
            } else {
                // Show selected argument detail or synthesis preview
                selectedArgumentDetail
            }
        }
        .background(Color(hex: "0F1419"))
    }

    @ViewBuilder
    private var rebuttalContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.counterArguments.indices, id: \.self) { index in
                    let argument = viewModel.counterArguments[index]
                    iPadRebuttalCard(
                        argument: argument,
                        rebuttal: $viewModel.rebuttals[index],
                        isJudging: viewModel.currentJudgmentIndex == index,
                        isSelected: selectedArgumentId == argument.id
                    ) {
                        selectedArgumentId = argument.id
                        Task {
                            await viewModel.judgeRebuttal(at: index)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var selectedArgumentDetail: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let selectedId = selectedArgumentId,
                   let argument = viewModel.counterArguments.first(where: { $0.id == selectedId }) {
                    // Show selected argument expanded
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(argument.type.icon)
                                .font(.system(size: 16))
                            Text(argument.type.rawValue)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: argument.confidenceLevel.color))
                            Spacer()
                        }

                        Text(argument.text)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.white)
                            .lineSpacing(4)

                        Text(argument.type.description)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        if !argument.citations.isEmpty {
                            CitationsListView(citations: argument.citations)
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)

                    // Prompt to enter rebuttal
                    Text("Tap 'Respond to All' to enter your rebuttals side-by-side.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "8B9BB4"))
                        .multilineTextAlignment(.center)
                        .padding(20)

                } else {
                    // No argument selected — show topic
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.left.and.right.square")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "4A90D9").opacity(0.5))

                        Text("Select an argument to see its details")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        Text("Then respond with your rebuttal in the right panel")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "6B7280"))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                }
            }
            .padding(.top, 16)
        }
    }

    private func binding(for argumentId: UUID) -> Binding<Rebuttal>? {
        guard let index = viewModel.counterArguments.firstIndex(where: { $0.id == argumentId }) else {
            return nil
        }
        return $viewModel.rebuttals[index]
    }
}

// MARK: - iPad Argument Row

struct iPadArgumentRow: View {
    let argument: CounterArgument
    let isSelected: Bool
    let rebuttal: Binding<Rebuttal>?
    let onSelect: () -> Void

    private var strengthColor: Color {
        Color(hex: argument.confidenceLevel.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(argument.type.icon)
                    .font(.system(size: 12))

                Text(argument.type.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(strengthColor)

                Spacer()

                if rebuttal?.wrappedValue.judgment != .weak {
                    Image(systemName: rebuttal?.wrappedValue.judgment == .strong ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(rebuttal?.wrappedValue.judgment == .strong ? Color(hex: "52B788") : Color(hex: "F4A261"))
                }
            }

            Text(argument.text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(isSelected ? 10 : 3)
                .lineSpacing(3)

            if !argument.citations.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 9))
                    Text("\(argument.citations.count) source(s)")
                        .font(.system(size: 9))
                }
                .foregroundColor(Color(hex: "4A90D9"))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: isSelected ? "243044" : "1A2332"))
        )
        .overlay(
            Rectangle()
                .fill(strengthColor)
                .frame(width: 3),
            alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - iPad Rebuttal Card

struct iPadRebuttalCard: View {
    let argument: CounterArgument
    @Binding var rebuttal: Rebuttal
    let isJudging: Bool
    let isSelected: Bool
    let onSubmit: () -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Argument header
            HStack(spacing: 5) {
                Text(argument.type.icon)
                    .font(.system(size: 11))
                Text(argument.type.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: argument.confidenceLevel.color))

                Spacer()

                if isJudging {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Color(hex: "4A90D9"))
                } else if rebuttal.judgment != .weak {
                    Text(rebuttal.judgment.icon)
                        .font(.system(size: 12))
                }
            }

            Text(argument.text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineLimit(4)

            Divider()
                .background(Color(hex: "2D3F54"))

            // Rebuttal text editor
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "1A2332"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color(hex: "4A90D9") : Color(hex: "2D3F54"), lineWidth: 1)
                    )

                TextEditor(text: $text)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 80)
                    .onChange(of: text) { _, newValue in
                        rebuttal.text = newValue
                    }
                    .onAppear {
                        text = rebuttal.text
                    }

                if text.isEmpty {
                    Text("Write your rebuttal here...")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6B7280"))
                        .padding(14)
                        .allowsHitTesting(false)
                }
            }

            // Character count + submit
            HStack {
                Text("\(text.count) chars")
                    .font(.system(size: 10))
                    .foregroundColor(text.count >= 20 ? Color(hex: "52B788") : Color(hex: "6B7280"))

                Spacer()

                Button(action: {
                    rebuttal.text = text
                    onSubmit()
                }) {
                    Text(isJudging ? "Judging..." : "Submit")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color(hex: "4A90D9")))
                }
                .disabled(isJudging || text.count < 20)
            }
        }
        .padding(12)
        .background(Color(hex: "1A2332"))
        .cornerRadius(8)
        .overlay(
            Rectangle()
                .fill(Color(hex: argument.confidenceLevel.color))
                .frame(width: 3),
            alignment: .leading
        )
        .onAppear {
            text = rebuttal.text
        }
    }
}
