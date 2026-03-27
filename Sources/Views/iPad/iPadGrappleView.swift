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
                    .background(Theme.Colors.divider)
                    .frame(width: 1)

                // Right panel: Rebuttal or Synthesis
                rebuttalPanel
                    .frame(width: geometry.size.width * 0.55)
            }
        }
        .background(Theme.Colors.background)
    }

    // MARK: - Argument Panel (Left)

    @ViewBuilder
    private var argumentPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: viewModel.debateMode.icon)
                        .font(.system(size: Theme.Typography.body))
                        .foregroundColor(Theme.Colors.primary)
                    Text(viewModel.debateMode.rawValue)
                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.primary)
                    Spacer()
                    Text("\(viewModel.counterArguments.count) arguments")
                        .font(Theme.Typography.text(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Text(viewModel.debateMode == .opposingView ?
                     "AI argues the opposing view. Respond to each challenge." :
                     "Strongest challenges to your thinking. Select to respond.")
                    .font(Theme.Typography.text(Theme.Typography.bodySmall))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(3)
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)

            Divider()
                .background(Theme.Colors.divider)

            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.counterArguments) { argument in
                        iPadArgumentRow(
                            argument: argument,
                            isSelected: selectedArgumentId == argument.id,
                            rebuttal: binding(for: argument.id)
                        ) {
                            Haptics.cardTap()
                            selectedArgumentId = argument.id
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.divider)

                if viewModel.debateMode.hasRebuttal {
                    Button(action: {
                        Haptics.buttonTap()
                        viewModel.proceedToRebuttal()
                    }) {
                        HStack {
                            Text("Respond to All")
                                .font(Theme.Typography.textSemibold(Theme.Typography.bodyLarge))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg).fill(Theme.Colors.primary))
                    }
                    .accessibilityLabel("Respond to all counter-arguments")
                } else {
                    Button(action: {
                        Haptics.grappleStart()
                        Task { await viewModel.submitRebuttals() }
                    }) {
                        HStack {
                            Text("View Synthesis")
                                .font(Theme.Typography.textSemibold(Theme.Typography.bodyLarge))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg).fill(Theme.Colors.success))
                    }
                    .accessibilityLabel("View synthesis")
                }
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
        }
        .background(Theme.Colors.background)
    }

    // MARK: - Rebuttal Panel (Right)

    @ViewBuilder
    private var rebuttalPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: Theme.Typography.body))
                        .foregroundColor(Theme.Colors.success)
                    Text("Your Response")
                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.success)

                    Spacer()

                    if !viewModel.rebuttalsEntered.description.isEmpty {
                        Text("\(viewModel.rebuttalsEntered) of \(viewModel.counterArguments.count) entered")
                            .font(Theme.Typography.text(Theme.Typography.caption))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }

                if let selectedId = selectedArgumentId,
                   let argument = viewModel.counterArguments.first(where: { $0.id == selectedId }) {
                    Text("Responding to: \(argument.text.prefix(80))...")
                        .font(Theme.Typography.text(Theme.Typography.caption2))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                } else {
                    Text("Select an argument on the left to write your rebuttal.")
                        .font(Theme.Typography.text(Theme.Typography.bodySmall))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)

            Divider()
                .background(Theme.Colors.divider)

            if viewModel.phase == .rebuttal || viewModel.phase == .judgingRebuttals || viewModel.phase == .synthesizing {
                rebuttalContent
            } else {
                // Show selected argument detail or synthesis preview
                selectedArgumentDetail
            }
        }
        .background(Theme.Colors.background)
    }

    @ViewBuilder
    private var rebuttalContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
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
            .padding(Theme.Spacing.lg)
        }
    }

    @ViewBuilder
    private var selectedArgumentDetail: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let selectedId = selectedArgumentId,
                   let argument = viewModel.counterArguments.first(where: { $0.id == selectedId }) {
                    // Show selected argument expanded
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Text(argument.type.icon)
                                .font(.system(size: Theme.Typography.bodyLarge))
                            Text(argument.type.rawValue)
                                .font(Theme.Typography.monoSemibold(Theme.Typography.bodySmall))
                                .foregroundColor(Color(hex: argument.confidenceLevel.color))
                            Spacer()
                        }

                        Text(argument.text)
                            .font(Theme.Typography.mono(Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(4)

                        Text(argument.type.description)
                            .font(Theme.Typography.text(Theme.Typography.caption2))
                            .foregroundColor(Theme.Colors.textSecondary)

                        if !argument.citations.isEmpty {
                            CitationsListView(citations: argument.citations)
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.lg)
                    .padding(.horizontal, Theme.Spacing.lg)

                    // Prompt to enter rebuttal
                    Text("Tap 'Respond to All' to enter your rebuttals side-by-side.")
                        .font(Theme.Typography.text(Theme.Typography.bodySmall))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(20)

                } else {
                    // No argument selected — show topic
                    VStack(spacing: Theme.Spacing.lg) {
                        Image(systemName: "arrow.left.and.right.square")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.Colors.primary.opacity(0.5))

                        Text("Select an argument to see its details")
                            .font(Theme.Typography.text(Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textSecondary)

                        Text("Then respond with your rebuttal in the right panel")
                            .font(Theme.Typography.text(Theme.Typography.bodySmall))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(40)
                }
            }
            .padding(.top, Theme.Spacing.lg)
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
                    .font(.system(size: Theme.Typography.bodySmall))

                Text(argument.type.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(strengthColor)

                Spacer()

                if rebuttal?.wrappedValue.judgment != .weak {
                    Image(systemName: rebuttal?.wrappedValue.judgment == .strong ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: Theme.Typography.bodySmall))
                        .foregroundColor(rebuttal?.wrappedValue.judgment == .strong ? Theme.Colors.success : Theme.Colors.warning)
                }
            }

            Text(argument.text)
                .font(Theme.Typography.mono(Theme.Typography.bodySmall))
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(isSelected ? 10 : 3)
                .lineSpacing(3)

            if !argument.citations.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 9))
                    Text("\(argument.citations.count) source(s)")
                        .font(Theme.Typography.text(9))
                }
                .foregroundColor(Theme.Colors.primary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .fill(isSelected ? Theme.Colors.surfaceElevated : Theme.Colors.surface)
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
                    .font(.system(size: Theme.Typography.bodySmall))
                Text(argument.type.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(Color(hex: argument.confidenceLevel.color))

                Spacer()

                if isJudging {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Theme.Colors.primary)
                } else if rebuttal.judgment != .weak {
                    Text(rebuttal.judgment.icon)
                        .font(.system(size: Theme.Typography.bodySmall))
                }
            }

            Text(argument.text)
                .font(Theme.Typography.mono(Theme.Typography.bodySmall))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(4)

            Divider()
                .background(Theme.Colors.divider)

            // Rebuttal text editor
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .fill(Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                            .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.divider, lineWidth: 1)
                    )

                TextEditor(text: $text)
                    .font(Theme.Typography.text(Theme.Typography.bodySmall))
                    .foregroundColor(Theme.Colors.textPrimary)
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
                        .font(Theme.Typography.text(Theme.Typography.bodySmall))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(14)
                        .allowsHitTesting(false)
                }
            }

            // Character count + submit
            HStack {
                Text("\(text.count) chars")
                    .font(Theme.Typography.text(10))
                    .foregroundColor(text.count >= 20 ? Theme.Colors.success : Theme.Colors.textTertiary)

                Spacer()

                Button(action: {
                    Haptics.judgmentReceived()
                    rebuttal.text = text
                    onSubmit()
                }) {
                    Text(isJudging ? "Judging..." : "Submit")
                        .font(Theme.Typography.textSemibold(Theme.Typography.caption))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.sm).fill(Theme.Colors.primary))
                }
                .disabled(isJudging || text.count < 20)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
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
