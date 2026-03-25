import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @EnvironmentObject var databaseService: DatabaseService

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419")
                    .ignoresSafeArea()

                if viewModel.sessions.isEmpty {
                    EmptyHistoryView()
                } else {
                    SessionListView(viewModel: viewModel)
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
