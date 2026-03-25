import SwiftUI

struct GrappleView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @State private var expandedArgumentIds: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Grapple")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Here are the strongest challenges to your thinking. Tap each to expand.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B9BB4"))
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Arguments
                    VStack(spacing: 12) {
                        ForEach(viewModel.counterArguments) { argument in
                            ArgumentCard(
                                argument: argument,
                                isExpanded: expandedArgumentIds.contains(argument.id),
                                onToggle: {
                                    if expandedArgumentIds.contains(argument.id) {
                                        expandedArgumentIds.remove(argument.id)
                                    } else {
                                        expandedArgumentIds.insert(argument.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    // Summary badge
                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 12))

                        Text("\(viewModel.counterArguments.count) challenges across \(ArgumentType.allCases.count) categories")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "8B9BB4"))
                    .padding(.horizontal, 16)

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "2D3F54"))

                Button(action: {
                    // Already transitioning via phase change
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
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(hex: "0F1419"))
        }
    }
}
