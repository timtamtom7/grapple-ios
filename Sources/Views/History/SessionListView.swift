import SwiftUI

struct SessionListView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        List {
            ForEach(viewModel.sessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    SessionRow(session: session)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewModel.delete(viewModel.sessions[index])
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "0F1419"))
    }
}
