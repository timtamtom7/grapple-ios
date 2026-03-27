import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var databaseService: DatabaseService
    @State private var searchText = ""
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textSecondary)

                        TextField("Search sessions...", text: $searchText)
                            .font(Theme.Typography.text(Theme.Typography.body))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button(action: {
                                Haptics.lightImpact()
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .cornerRadius(Theme.CornerRadius.lg)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, 8)

                    // Topic tracking bar
                    if !viewModel.topTopics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.topTopics, id: \.topic) { topicStat in
                                    Button(action: {
                                        Haptics.lightImpact()
                                        searchText = topicStat.topic
                                    }) {
                                        HStack(spacing: 4) {
                                            Text(topicStat.topic)
                                                .font(Theme.Typography.textMedium(Theme.Typography.caption))
                                            Text("\(topicStat.count)")
                                                .font(Theme.Typography.mono(Theme.Typography.caption))
                                                .foregroundColor(Theme.Colors.primary)
                                        }
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Theme.Colors.surfaceElevated)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.lg)
                        }
                        .padding(.top, 8)
                    }

                    // Segment control: All / Topics
                    HStack(spacing: 0) {
                        SegmentButton(title: "All", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        SegmentButton(title: "By Topic", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.md)

                    if viewModel.filteredSessions(searchText).isEmpty {
                        Spacer()
                        EmptyHistoryView()
                        Spacer()
                    } else {
                        List {
                            if selectedTab == 0 {
                                ForEach(viewModel.filteredSessions(searchText)) { session in
                                    NavigationLink(destination: SessionDetailView(session: session)) {
                                        SessionRow(session: session)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                }
                                .onDelete { indexSet in
                                    Haptics.delete()
                                    for index in indexSet {
                                        viewModel.delete(viewModel.filteredSessions(searchText)[index])
                                    }
                                }
                            } else {
                                // Grouped by topic
                                ForEach(viewModel.groupedFiltered(searchText), id: \.key) { group in
                                    Section(header: Text(group.key)
                                        .font(Theme.Typography.monoSemibold(Theme.Typography.caption))
                                        .foregroundColor(Theme.Colors.primary)
                                        .textCase(nil)) {
                                        ForEach(group.value) { session in
                                            NavigationLink(destination: SessionDetailView(session: session)) {
                                                SessionRow(session: session)
                                            }
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Theme.Colors.background)
                    }
                }
            }
            .navigationTitle("History")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            #endif
        }
        .onAppear {
            viewModel.load()
        }
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.tabSwitch()
            action()
        }) {
            Text(title)
                .font(Theme.Typography.textSemibold(Theme.Typography.bodySmall))
                .foregroundColor(isSelected ? .white : Theme.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Theme.Colors.primary : Color.clear)
                .cornerRadius(Theme.CornerRadius.md)
        }
        .accessibilityLabel("Tab: \(title)")
        .accessibilityHint(isSelected ? "Currently selected" : "Double-tap to select")
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            GrappleEmptyIllustration(size: 160)

            Text("No sessions yet")
                .font(Theme.Typography.displayBold(20))
                .foregroundColor(Theme.Colors.textSecondary)

            Text("Start a new Grapple session to test your thinking.")
                .font(Theme.Typography.text(Theme.Typography.body))
                .foregroundColor(Theme.Colors.divider)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
