import SwiftUI

struct SynthesisView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @State private var showFactChecks = true
    @State private var appeared = false
    @State private var navigateToHistory = false
    @State private var showingShareSheet = false
    @State private var showPublishSheet = false
    @State private var isPublished = false
    @State private var selectedCategory = "General"
    @State private var publishConfirm = false
    @State private var sharePDFURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with dramatic reveal
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Theme.Colors.success)
                            Text("Synthesis Complete")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.success)
                        }

                        Text("Here's how your thinking held up under pressure.")
                            .font(Theme.Typography.text(Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.xxl)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

                    if let synth = viewModel.synthesis {
                        // Overall confidence banner
                        HStack(spacing: 8) {
                            Image(systemName: synth.overallConfidence == .high ? "checkmark.circle.fill" : (synth.overallConfidence == .medium ? "exclamationmark.circle.fill" : "xmark.circle.fill"))
                                .font(.system(size: 16))
                            Text("Overall Confidence: \(synth.overallConfidence.rawValue)")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.bodySmall))
                        }
                        .foregroundColor(Color(hex: synth.overallConfidence.color))
                        .padding(.horizontal, Theme.Spacing.lg)

                        // Verdict banner
                        VStack(spacing: Theme.Spacing.md) {
                            Text("Final Verdict")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                .foregroundColor(Theme.Colors.success)

                            Text(synth.verdict)
                                .font(Theme.Typography.textMedium(Theme.Typography.bodyLarge))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            Theme.Colors.success.opacity(0.08)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .stroke(Theme.Colors.success.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(Theme.CornerRadius.lg)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.95)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                        // Sections
                        SynthesisSection(
                            title: "What Survived",
                            icon: "✅",
                            content: synth.whatSurvived,
                            color: Theme.Colors.success
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3), value: appeared)

                        SynthesisSection(
                            title: "What Collapsed",
                            icon: "❌",
                            content: synth.whatCollapsed,
                            color: Theme.Colors.danger
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.4), value: appeared)

                        SynthesisSection(
                            title: "Needs Evidence",
                            icon: "🔍",
                            content: synth.needsEvidence,
                            color: Theme.Colors.warning
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.5), value: appeared)

                        // Fact Check Section
                        if !synth.factChecks.isEmpty {
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: Theme.Typography.caption2))
                                        .foregroundColor(Theme.Colors.primary)
                                    Text("Real-Time Fact Check")
                                        .font(Theme.Typography.textSemibold(Theme.Typography.body))
                                        .foregroundColor(Theme.Colors.primary)

                                    Spacer()

                                    Button(action: {
                                        Haptics.toggle()
                                        showFactChecks.toggle()
                                    }) {
                                        Image(systemName: showFactChecks ? "chevron.up" : "chevron.down")
                                            .font(.system(size: Theme.Typography.caption2, weight: .semibold))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    .accessibilityLabel(showFactChecks ? "Collapse fact checks" : "Expand fact checks")
                                }

                                if showFactChecks {
                                    ForEach(synth.factChecks) { item in
                                        FactCheckCard(item: item)
                                    }
                                }
                            }
                            .padding(Theme.Spacing.lg)
                            .background(Theme.Colors.surface)
                            .cornerRadius(Theme.CornerRadius.md)
                            .overlay(
                                Rectangle()
                                    .fill(Theme.Colors.primary)
                                    .frame(width: 3),
                                alignment: .leading
                            )
                            .padding(.horizontal, Theme.Spacing.lg)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 15)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.6), value: appeared)
                        }

                        // Stats summary
                        HStack(spacing: Theme.Spacing.md) {
                            StatBadge(
                                label: "Strong",
                                count: viewModel.rebuttals.filter { $0.judgment == .strong }.count,
                                color: Theme.Colors.success
                            )
                            StatBadge(
                                label: "Partial",
                                count: viewModel.rebuttals.filter { $0.judgment == .partial }.count,
                                color: Theme.Colors.warning
                            )
                            StatBadge(
                                label: "Weak",
                                count: viewModel.rebuttals.filter { $0.judgment == .weak }.count,
                                color: Theme.Colors.danger
                            )
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.7), value: appeared)

                        // Export as PDF
                        Button(action: {
                            Haptics.lightImpact()
                            exportPDF()
                        }) {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: Theme.Typography.bodySmall))
                                Text("Export as PDF")
                                    .font(Theme.Typography.textSemibold(Theme.Typography.body))
                            }
                            .foregroundColor(Theme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.lg - 2)
                            .background(Theme.Colors.surface)
                            .cornerRadius(Theme.CornerRadius.lg)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.8), value: appeared)
                        .accessibilityLabel("Export synthesis as PDF")
                    }

                    Spacer(minLength: 100)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.divider)

                HStack(spacing: Theme.Spacing.md) {
                    Button(action: {
                        Haptics.buttonTap()
                        viewModel.reset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15, weight: .semibold))

                            Text("New Grapple")
                                .font(Theme.Typography.textSemibold(Theme.Typography.button))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .fill(Theme.Colors.surfaceElevated)
                        )
                    }
                    .accessibilityLabel("Start a new Grapple session")

                    Button(action: {
                        Haptics.success()
                        viewModel.reset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .semibold))

                            Text("Change my Mind")
                                .font(Theme.Typography.textSemibold(Theme.Typography.button))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .fill(Theme.Colors.primary)
                        )
                    }
                    .accessibilityLabel("Change my mind and revise argument")

                    // Publish to community button
                    Button(action: {
                        Haptics.buttonTap()
                        showPublishSheet = true
                    }) {
                        HStack {
                            Image(systemName: isPublished ? "checkmark.circle.fill" : "globe")
                                .font(.system(size: 15, weight: .semibold))
                            Text(isPublished ? "Published" : "Share")
                                .font(Theme.Typography.textSemibold(Theme.Typography.button))
                        }
                        .foregroundColor(isPublished ? Theme.Colors.success : Theme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .fill(isPublished ? Theme.Colors.success.opacity(0.15) : Theme.Colors.primary.opacity(0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .stroke(isPublished ? Theme.Colors.success.opacity(0.4) : Theme.Colors.primary.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel(isPublished ? "Published to community" : "Share with community")

                    NavigationLink(destination: HistoryView(viewModel: historyViewModel)) {
                        HStack {
                            Text("History")
                                .font(Theme.Typography.textSemibold(Theme.Typography.button))

                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                                .fill(Theme.Colors.surfaceElevated)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("View session history")
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
        }
        .sheet(isPresented: $showingShareSheet) {
            #if canImport(UIKit)
            if let url = sharePDFURL {
                ShareSheet(activityItems: [url])
            }
            #endif
        }
        .sheet(isPresented: $showPublishSheet) {
            PublishSheet(
                isPublished: $isPublished,
                selectedCategory: $selectedCategory,
                onPublish: publishSession
            )
        }
        .onAppear {
            appeared = true
            Haptics.synthesisComplete()
        }
    }

    private func publishSession() {
        publishConfirm = true
        isPublished = true
    }

    private func exportPDF() {
        let session = GrappleSession(
            topic: viewModel.topic,
            originalInput: viewModel.inputText,
            counterArguments: viewModel.counterArguments,
            rebuttals: viewModel.rebuttals,
            synthesis: viewModel.synthesis,
            outcome: .mixed,
            debateMode: viewModel.debateMode,
            sourceURLs: viewModel.sourceURLs,
            factChecks: viewModel.synthesis?.factChecks ?? []
        )
        sharePDFURL = PDFExportService.shared.saveSynthesisPDF(session: session)
        if sharePDFURL != nil {
            showingShareSheet = true
        }
    }
}

struct SynthesisSection: View {
    let title: String
    let icon: String
    let content: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Text(icon)
                    .font(.system(size: Theme.Typography.body))

                Text(title)
                    .font(Theme.Typography.textSemibold(Theme.Typography.body))
                    .foregroundColor(color)
            }

            Text(content)
                .font(Theme.Typography.text(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            Rectangle()
                .fill(color)
                .frame(width: 3),
            alignment: .leading
        )
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

struct StatBadge: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(Theme.Typography.displayBold(24))
                .foregroundColor(color)

            Text(label)
                .font(Theme.Typography.text(Theme.Typography.caption))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

struct FactCheckCard: View {
    let item: FactCheckItem

    var confidenceColor: Color {
        Color(hex: item.confidence.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: 6) {
                Circle()
                    .fill(confidenceColor)
                    .frame(width: 6, height: 6)
                Text(item.confidence.rawValue)
                    .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                    .foregroundColor(confidenceColor)
            }

            Text("\"\(item.claim)\"")
                .font(Theme.Typography.mono(Theme.Typography.caption2))
                .foregroundColor(Theme.Colors.danger)
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.system(size: Theme.Typography.caption))
                Text(item.actualData)
                    .font(Theme.Typography.text(Theme.Typography.caption2))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surfaceElevated)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Publish Sheet

struct PublishSheet: View {
    @Binding var isPublished: Bool
    @Binding var selectedCategory: String
    let onPublish: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var topic: String = ""

    private let categories = TopicCategory.samples

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Share with Community")
                                .font(Theme.Typography.displayBold(20))
                                .foregroundColor(Theme.Colors.textPrimary)

                            Text("Your grappling session will be shared publicly so others can learn from your thinking.")
                                .font(Theme.Typography.text(Theme.Typography.bodySmall))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .lineSpacing(3)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Category")
                                .font(Theme.Typography.monoSemibold(Theme.Typography.caption2))
                                .foregroundColor(Theme.Colors.textSecondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(categories) { cat in
                                    Button(action: {
                                        Haptics.selectionChanged()
                                        selectedCategory = cat.name
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: Theme.Typography.caption))
                                            Text(cat.name)
                                                .font(Theme.Typography.textMedium(Theme.Typography.caption2))
                                            Spacer()
                                        }
                                        .foregroundColor(selectedCategory == cat.name ? .white : Theme.Colors.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                                .fill(selectedCategory == cat.name ? Color(hex: cat.color).opacity(0.3) : Theme.Colors.surface)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                                .stroke(selectedCategory == cat.name ? Color(hex: cat.color) : Theme.Colors.divider, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 20)

                        Button(action: {
                            Haptics.success()
                            onPublish()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Publish to Community")
                                    .font(Theme.Typography.textSemibold(Theme.Typography.body))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.lg)
                            .background(RoundedRectangle(cornerRadius: Theme.CornerRadius.lg).fill(Theme.Colors.success))
                        }
                        .accessibilityLabel("Publish to community")
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Publish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
