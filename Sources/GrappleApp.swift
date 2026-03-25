import SwiftUI
#if canImport(UIKit)
@main
struct GrappleApp: App {
    @StateObject private var databaseService = DatabaseService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(databaseService)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
