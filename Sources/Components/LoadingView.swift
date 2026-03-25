import SwiftUI

struct LoadingView: View {
    let message: String

    @State private var opacity: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(hex: "4A90D9"))

            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "8B9BB4"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "0F1419"))
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}
