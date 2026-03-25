import SwiftUI

struct ContentView: View {
    @StateObject private var grappleViewModel = GrappleViewModel()
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var selectedTab = 0
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        Group {
            #if canImport(UIKit)
            if Platform.isIPad {
                iPadContentView
            } else {
                iPhoneContentView
            }
            #else
            iPhoneContentView
            #endif
        }
        #if canImport(UIKit)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "0F1419"))
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        #endif
    }

    private var iPhoneContentView: some View {
        TabView(selection: $selectedTab) {
            GrappleFlowView(viewModel: grappleViewModel, historyViewModel: historyViewModel)
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
    }

    private var iPadContentView: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                NavigationLink(destination: GrappleFlowView(viewModel: grappleViewModel, historyViewModel: historyViewModel)) {
                    Label("New Grapple", systemImage: "square.and.pencil")
                }

                NavigationLink(destination: HistoryView(viewModel: historyViewModel)) {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            }
            .navigationTitle("Grapple")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        } detail: {
            // Detail column: shows the current grapple flow
            NavigationStack {
                ZStack {
                    Color(hex: "0F1419").ignoresSafeArea()

                    GrappleFlowView(viewModel: grappleViewModel, historyViewModel: historyViewModel)
                }
                .navigationTitle("Grapple")
                #if canImport(UIKit)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
        }
        .tint(Color(hex: "4A90D9"))
    }
}

struct GrappleFlowView: View {
    @ObservedObject var viewModel: GrappleViewModel
    @ObservedObject var historyViewModel: HistoryViewModel

    private var isIPad: Bool {
        Platform.isIPad
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F1419")
                    .ignoresSafeArea()

                if isIPad && (viewModel.phase == .arguments || viewModel.phase == .rebuttal) {
                    iPadGrappleView(viewModel: viewModel, historyViewModel: historyViewModel)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    phoneFlowContent
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.phase)
        }
        .alert("Something went wrong", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                viewModel.showError = false
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unexpected error occurred. Please try again.")
        }
    }

    @ViewBuilder
    private var phoneFlowContent: some View {
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
            SynthesisView(viewModel: viewModel, historyViewModel: historyViewModel)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }
}
