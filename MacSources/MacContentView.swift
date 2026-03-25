import SwiftUI
import AppKit

struct MacContentView: View {
    @StateObject private var grappleViewModel = GrappleViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: MacGrappleFlowView(viewModel: grappleViewModel, historyViewModel: historyViewModel)) {
                    Label("New Grapple", systemImage: "square.and.pencil")
                }
                NavigationLink(destination: MacHistoryView(viewModel: historyViewModel)) {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
            .navigationTitle("Grapple")
        } detail: {
            MacGrappleFlowView(viewModel: grappleViewModel, historyViewModel: historyViewModel)
        }
        .frame(minWidth: 800, idealWidth: 1000, minHeight: 600)
        .tint(Color(hex: "4A90D9"))
    }
}
