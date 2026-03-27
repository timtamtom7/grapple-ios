import SwiftUI

struct RealTimeFactCheckView: View {
    let claim: String
    @State private var result: FactCheckItem?
    @State private var isChecking = false
    @State private var hasChecked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: Theme.Typography.caption))

                Text("Fact Check")
                    .font(Theme.Typography.textSemibold(Theme.Typography.caption))
                    .foregroundColor(Theme.Colors.primary)

                Spacer()

                if isChecking {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Theme.Colors.primary)
                } else if let result = result {
                    confidenceBadge(for: result)
                }
            }

            // Claim
            Text("\"\(claim)\"")
                .font(Theme.Typography.mono(Theme.Typography.caption))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(3)

            if isChecking {
                Text("Checking claim accuracy...")
                    .font(Theme.Typography.text(10))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .italic()
            } else if let result = result {
                // Result
                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: Theme.Typography.caption))
                        .foregroundColor(Color(hex: result.confidence.color))
                    Text(result.actualData)
                        .font(Theme.Typography.text(Theme.Typography.caption))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(4)
                }
            }
        }
        .padding(10)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(Theme.Colors.primary.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func confidenceBadge(for item: FactCheckItem) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(Color(hex: item.confidence.color))
                .frame(width: 5, height: 5)
            Text(item.confidence.rawValue)
                .font(Theme.Typography.monoSemibold(9))
                .foregroundColor(Color(hex: item.confidence.color))
        }
    }
}

struct FactCheckButton: View {
    let claim: String
    let onCheck: (String) async -> FactCheckItem?

    @State private var result: FactCheckItem?
    @State private var isChecking = false
    @State private var showResult = false

    var body: some View {
        Button(action: {
            Haptics.lightImpact()
            runFactCheck()
        }) {
            HStack(spacing: 4) {
                if isChecking {
                    ProgressView()
                        .scaleEffect(0.5)
                        .tint(Theme.Colors.warning)
                } else if let result = result {
                    Image(systemName: result.confidence == .high ? "checkmark.circle.fill" : (result.confidence == .medium ? "exclamationmark.circle.fill" : "xmark.circle.fill"))
                        .font(.system(size: 10))
                    Text("Fact Checked")
                        .font(Theme.Typography.textMedium(Theme.Typography.caption))
                } else {
                    Image(systemName: "shield")
                        .font(.system(size: 10))
                    Text("Fact Check")
                        .font(Theme.Typography.textMedium(Theme.Typography.caption))
                }
            }
            .foregroundColor(result != nil ? Color(hex: result!.confidence.color) : Theme.Colors.warning)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((result != nil ? Color(hex: result!.confidence.color) : Theme.Colors.warning).opacity(0.12))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showResult) {
            if let result = result {
                FactCheckResultSheet(claim: claim, result: result)
            }
        }
        .disabled(isChecking)
        .accessibilityLabel(result != nil ? "Fact check complete" : "Run fact check")
    }

    private func runFactCheck() {
        guard !isChecking else { return }
        isChecking = true

        Task {
            if let checked = await onCheck(claim) {
                await MainActor.run {
                    self.result = checked
                    self.isChecking = false
                    self.showResult = true
                }
            } else {
                await MainActor.run {
                    self.isChecking = false
                }
            }
        }
    }
}

struct FactCheckResultSheet: View {
    let claim: String
    let result: FactCheckItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: result.confidence.color))

                            Text("Fact Check Result")
                                .font(Theme.Typography.displayBold(18))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }

                        // Confidence badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: result.confidence.color))
                                .frame(width: 8, height: 8)
                            Text(result.confidence.rawValue)
                                .font(Theme.Typography.monoSemibold(Theme.Typography.bodySmall))
                                .foregroundColor(Color(hex: result.confidence.color))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: result.confidence.color).opacity(0.12))
                        .cornerRadius(20)

                        // Claim
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CLAIM")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.textSecondary)

                            Text("\"\(claim)\"")
                                .font(Theme.Typography.mono(Theme.Typography.body))
                                .foregroundColor(Theme.Colors.danger)
                                .padding(12)
                                .background(Theme.Colors.danger.opacity(0.08))
                                .cornerRadius(Theme.CornerRadius.md)
                        }

                        // Assessment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ASSESSMENT")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.textSecondary)

                            Text(result.actualData)
                                .font(Theme.Typography.text(Theme.Typography.body))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(4)
                                .padding(12)
                                .background(Theme.Colors.surface)
                                .cornerRadius(Theme.CornerRadius.md)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Fact Check")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            #endif
        }
    }
}
