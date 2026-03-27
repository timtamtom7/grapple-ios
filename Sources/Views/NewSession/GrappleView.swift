import SwiftUI

struct GrappleView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @State private var expandedArgumentIds: Set<UUID> = Set()
    @State private var appearedArgumentIds: Set<UUID> = Set()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: true) {
                argumentsContent
            }

            bottomCTA
        }
    }

    @ViewBuilder
    private var argumentsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection

            argumentsList

            summaryBadge

            Spacer(minLength: 100)
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: viewModel.debateMode.icon)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.primary)
                Text(viewModel.debateMode.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(Theme.Colors.primary)
            }

            Text("Grapple")
                .font(Theme.Typography.displaySemibold(Theme.Typography.heading1))
                .foregroundColor(Theme.Colors.textPrimary)

            Text(viewModel.debateMode == .opposingView ?
                 "AI is arguing the opposing view. Here's its strongest case against you." :
                 "Here are the strongest challenges to your thinking. Tap each to expand.")
                .font(Theme.Typography.text(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.xxl)
    }

    @ViewBuilder
    private var argumentsList: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(viewModel.counterArguments) { argument in
                cardView(for: argument)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    @ViewBuilder
    private func cardView(for argument: CounterArgument) -> some View {
        let isExpanded = expandedArgumentIds.contains(argument.id)
        let hasAppeared = appearedArgumentIds.contains(argument.id)

        ArgumentCard(
            argument: argument,
            isExpanded: isExpanded,
            onToggle: {
                Haptics.cardTap()
                if expandedArgumentIds.contains(argument.id) {
                    expandedArgumentIds.remove(argument.id)
                } else {
                    expandedArgumentIds.insert(argument.id)
                }
            },
            onFactCheck: { claim in
                await viewModel.checkClaimAccuracy(claim)
            }
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                _ = appearedArgumentIds.insert(argument.id)
            }
        }
    }

    @ViewBuilder
    private var summaryBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "target")
                .font(.system(size: Theme.Typography.caption2))

            Text("\(viewModel.counterArguments.count) \(viewModel.debateMode == .opposingView ? "opposing" : "challenge") arguments")
                .font(Theme.Typography.textMedium(Theme.Typography.caption2))
        }
        .foregroundColor(Theme.Colors.textSecondary)
        .padding(.horizontal, Theme.Spacing.lg)
    }

    @ViewBuilder
    private var bottomCTA: some View {
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
                            .font(Theme.Typography.textSemibold(Theme.Typography.button))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                            .fill(Theme.Colors.primary)
                    )
                }
                .accessibilityLabel("Respond to all counter-arguments")
                .accessibilityHint("Double-tap to proceed to the rebuttal phase")
            } else {
                Button(action: {
                    Haptics.grappleStart()
                    Task {
                        await viewModel.submitRebuttals()
                    }
                }) {
                    HStack {
                        Text("View Synthesis")
                            .font(Theme.Typography.textSemibold(Theme.Typography.button))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                            .fill(Theme.Colors.success)
                    )
                }
                .accessibilityLabel("View synthesis")
                .accessibilityHint("Double-tap to see how your thinking held up")
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.lg)
        .background(Theme.Colors.background)
    }
}
