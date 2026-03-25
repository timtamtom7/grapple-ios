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
                    .foregroundColor(Color(hex: "4A90D9"))
                Text(viewModel.debateMode.rawValue)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "4A90D9"))
            }

            Text("Grapple")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)

            Text(viewModel.debateMode == .opposingView ?
                 "AI is arguing the opposing view. Here's its strongest case against you." :
                 "Here are the strongest challenges to your thinking. Tap each to expand.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineSpacing(4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    @ViewBuilder
    private var argumentsList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.counterArguments) { argument in
                cardView(for: argument)
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func cardView(for argument: CounterArgument) -> some View {
        let isExpanded = expandedArgumentIds.contains(argument.id)
        let hasAppeared = appearedArgumentIds.contains(argument.id)

        ArgumentCard(
            argument: argument,
            isExpanded: isExpanded,
            onToggle: {
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
                .font(.system(size: 12))

            Text("\(viewModel.counterArguments.count) \(viewModel.debateMode == .opposingView ? "opposing" : "challenge") arguments")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color(hex: "8B9BB4"))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var bottomCTA: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(hex: "2D3F54"))

            if viewModel.debateMode.hasRebuttal {
                Button(action: {
                    viewModel.proceedToRebuttal()
                }) {
                    HStack {
                        Text("Respond to All")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "4A90D9"))
                    )
                }
            } else {
                Button(action: {
                    Task {
                        await viewModel.submitRebuttals()
                    }
                }) {
                    HStack {
                        Text("View Synthesis")
                            .font(.system(size: 17, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "52B788"))
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(hex: "0F1419"))
    }
}
