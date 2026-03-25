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
                    .font(.system(size: 11))

                Text("Fact Check")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "4A90D9"))

                Spacer()

                if isChecking {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Color(hex: "4A90D9"))
                } else if let result = result {
                    confidenceBadge(for: result)
                }
            }

            // Claim
            Text("\"\(claim)\"")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(hex: "8B9BB4"))
                .lineLimit(3)

            if isChecking {
                Text("Checking claim accuracy...")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "6B7280"))
                    .italic()
            } else if let result = result {
                // Result
                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: result.confidence.color))
                    Text(result.actualData)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8B9BB4"))
                        .lineLimit(4)
                }
            }
        }
        .padding(10)
        .background(Color(hex: "1A2332"))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "4A90D9").opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func confidenceBadge(for item: FactCheckItem) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(Color(hex: item.confidence.color))
                .frame(width: 5, height: 5)
            Text(item.confidence.rawValue)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
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
        Button(action: runFactCheck) {
            HStack(spacing: 4) {
                if isChecking {
                    ProgressView()
                        .scaleEffect(0.5)
                        .tint(Color(hex: "F4A261"))
                } else if let result = result {
                    Image(systemName: result.confidence == .high ? "checkmark.circle.fill" : (result.confidence == .medium ? "exclamationmark.circle.fill" : "xmark.circle.fill"))
                        .font(.system(size: 10))
                    Text("Fact Checked")
                        .font(.system(size: 10, weight: .medium))
                } else {
                    Image(systemName: "shield")
                        .font(.system(size: 10))
                    Text("Fact Check")
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .foregroundColor(result != nil ? Color(hex: result!.confidence.color) : Color(hex: "F4A261"))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((result != nil ? Color(hex: result!.confidence.color) : Color(hex: "F4A261")).opacity(0.12))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showResult) {
            if let result = result {
                FactCheckResultSheet(claim: claim, result: result)
            }
        }
        .disabled(isChecking)
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
                Color(hex: "0F1419").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: result.confidence.color))

                            Text("Fact Check Result")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        // Confidence badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: result.confidence.color))
                                .frame(width: 8, height: 8)
                            Text(result.confidence.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: result.confidence.color))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: result.confidence.color).opacity(0.12))
                        .cornerRadius(20)

                        // Claim
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CLAIM")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "8B9BB4"))

                            Text("\"\(claim)\"")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(hex: "E63946"))
                                .padding(12)
                                .background(Color(hex: "E63946").opacity(0.08))
                                .cornerRadius(8)
                        }

                        // Assessment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ASSESSMENT")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(hex: "8B9BB4"))

                            Text(result.actualData)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "8B9BB4"))
                                .lineSpacing(4)
                                .padding(12)
                                .background(Color(hex: "1A2332"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Fact Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "4A90D9"))
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
