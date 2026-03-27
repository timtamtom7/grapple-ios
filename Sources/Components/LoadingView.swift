import SwiftUI

struct LoadingView: View {
    let message: String

    @State private var opacity: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Theme.Colors.primary)

            Text(message)
                .font(Theme.Typography.textMedium(Theme.Typography.body))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}
