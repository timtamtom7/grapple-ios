import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var databaseService: DatabaseService
    @State private var searchText = ""
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8B9BB4"))

                        TextField("Search sessions...", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "8B9BB4"))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "1A2332"))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Topic tracking bar
                    if !viewModel.topTopics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.topTopics, id: \.topic) { topicStat in
                                    Button(action: { searchText = topicStat.topic }) {
                                        HStack(spacing: 4) {
                                            Text(topicStat.topic)
                                                .font(.system(size: 11, weight: .medium))
                                            Text("\(topicStat.count)")
                                                .font(.system(size: 10, design: .monospaced))
                                                .foregroundColor(Color(hex: "4A90D9"))
                                        }
                                        .foregroundColor(Color(hex: "8B9BB4"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "243044"))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
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
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

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
                                    for index in indexSet {
                                        viewModel.delete(viewModel.filteredSessions(searchText)[index])
                                    }
                                }
                            } else {
                                // Grouped by topic
                                ForEach(viewModel.groupedFiltered(searchText), id: \.key) { group in
                                    Section(header: Text(group.key)
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(Color(hex: "4A90D9"))
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
                        .background(Color(hex: "0F1419"))
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "0F1419"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color(hex: "8B9BB4"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "4A90D9") : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "2D3F54"))

            Text("No sessions yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "8B9BB4"))

            Text("Start a new Grapple session to test your thinking.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "2D3F54"))
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
