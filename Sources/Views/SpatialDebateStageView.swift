import SwiftUI

/// R14: Vision Pro spatial debate stage
/// Immersive debate experience
struct SpatialDebateStageView: View {
    @State private var currentPosition: DebatePosition = .audience
    @State private var isSessionActive = false
    @State private var currentArgument: ArgumentDisplay?

    enum DebatePosition: String, CaseIterable {
        case audience = "Audience"
        case proponent = "Proponent"
        case opponent = "Opponent"
        case judge = "Judge"

        var icon: String {
            switch self {
            case .audience: return "person.3.fill"
            case .proponent: return "checkmark.circle.fill"
            case .opponent: return "xmark.circle.fill"
            case .judge: return "scale.3d"
            }
        }
    }

    struct ArgumentDisplay: Identifiable {
        let id = UUID()
        let speaker: String
        let text: String
        let timestamp: Date
        let isCon: Bool
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E"), Color(hex: "0F3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Position selector
                positionSelector

                Spacer()

                // Main debate stage
                debateStage

                // Current argument
                if let argument = currentArgument {
                    argumentCard(argument)
                }

                Spacer()

                // Controls
                controlButtons
            }
            .padding()
        }
    }

    private var positionSelector: some View {
        HStack(spacing: 16) {
            ForEach(DebatePosition.allCases, id: \.self) { position in
                Button {
                    withAnimation {
                        currentPosition = position
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: position.icon)
                            .font(.title2)
                        Text(position.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(currentPosition == position ? .white : .gray)
                    .padding()
                    .background(currentPosition == position ? Color.white.opacity(0.2) : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var debateStage: some View {
        ZStack {
            // Stage circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 300, height: 300)

            // Position indicators
            HStack(spacing: 200) {
                // Proponent side
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Pro")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                // Opponent side
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("Con")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            // Audience indicator
            if currentPosition == .audience {
                Text("You are in the audience")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }

    @ViewBuilder
    private func argumentCard(_ argument: ArgumentDisplay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: argument.isCon ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(argument.isCon ? .red : .green)
                Text(argument.speaker)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(argument.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(argument.text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private var controlButtons: some View {
        HStack(spacing: 20) {
            if isSessionActive {
                Button {
                    isSessionActive = false
                } label: {
                    Label("End Debate", systemImage: "stop.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(12)
                }
            } else {
                Button {
                    startDebate()
                } label: {
                    Label("Start Debate", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green.opacity(0.6))
                        .cornerRadius(12)
                }
            }
        }
    }

    private func startDebate() {
        isSessionActive = true

        // Simulate arguments appearing
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            if !isSessionActive {
                timer.invalidate()
                return
            }

            let proArgs = [
                "This position is supported by current research...",
                "Historical evidence clearly demonstrates...",
                "The economic impact would be significant..."
            ]

            let conArgs = [
                "However, we must consider the unintended consequences...",
                "Alternative approaches have proven more effective...",
                "The data suggests a different conclusion..."
            ]

            let isCon = Bool.random()
            currentArgument = ArgumentDisplay(
                speaker: isCon ? "Opponent" : "Proponent",
                text: (isCon ? conArgs : proArgs).randomElement() ?? "",
                timestamp: Date(),
                isCon: isCon
            )
        }
    }
}
