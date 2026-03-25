import SwiftUI

struct ContentView: View {
    @StateObject private var grappleViewModel = GrappleViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GrappleFlowView(viewModel: grappleViewModel)
                .tabItem {
                    Label("New", systemImage: "square.and.pencil")
                }
                .tag(0)

            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
        }
        .tint(Color(hex: "4A90D9"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "0F1419"))
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct GrappleFlowView: View {
    @ObservedObject var viewModel: GrappleViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419")
                    .ignoresSafeArea()

                switch viewModel.phase {
                case .input:
                    InputView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .leading)))

                case .grappling, .judgingRebuttals, .synthesizing:
                    LoadingView(message: viewModel.loadingMessage)
                        .transition(.opacity)

                case .arguments:
                    GrappleView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))

                case .rebuttal:
                    RebuttalView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))

                case .quickComplete, .complete:
                    SynthesisView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.phase)
        }
    }
}
