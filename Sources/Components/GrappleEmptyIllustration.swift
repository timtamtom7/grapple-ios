import SwiftUI

/// A debate-themed illustration for Grapple's empty states.
struct GrappleEmptyIllustration: View {
    let size: CGFloat

    private let background = Color(hex: "0F1419")
    private let surface = Color(hex: "1A2332")
    private let blue = Color(hex: "4A90D9")
    private let mutedBlue = Color(hex: "2D3F54")
    private let textMuted = Color(hex: "8B9BB4")

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let scale = size / 300

            // Subtle background glow
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - 100 * scale,
                    y: center.y - 100 * scale,
                    width: 200 * scale,
                    height: 200 * scale
                )),
                with: .radialGradient(
                    Gradient(colors: [blue.opacity(0.06), Color.clear]),
                    center: center,
                    startRadius: 0,
                    endRadius: 100 * scale
                )
            )

            // Balance scale - simplified
            let cx = center.x
            let cy = center.y

            // Central pillar
            var pillarPath = Path()
            pillarPath.addRect(CGRect(x: cx - 6 * scale, y: cy - 80 * scale, width: 12 * scale, height: 120 * scale))
            context.fill(pillarPath, with: .color(surface))

            // Base
            var basePath = Path()
            basePath.addRect(CGRect(x: cx - 50 * scale, y: cy + 30 * scale, width: 100 * scale, height: 12 * scale))
            context.fill(basePath, with: .color(surface))

            // Beam (tilted)
            var beamPath = Path()
            beamPath.move(to: CGPoint(x: cx - 90 * scale, y: cy - 60 * scale))
            beamPath.addLine(to: CGPoint(x: cx + 90 * scale, y: cy - 40 * scale))
            context.stroke(beamPath, with: .color(mutedBlue), lineWidth: 4 * scale)

            // Left pan (down)
            var leftPanPath = Path()
            leftPanPath.addEllipse(in: CGRect(
                x: cx - 130 * scale - 40 * scale,
                y: cy - 20 * scale,
                width: 80 * scale,
                height: 20 * scale
            ))
            context.fill(leftPanPath, with: .color(surface))
            context.stroke(leftPanPath, with: .color(blue.opacity(0.4)), lineWidth: 1.5 * scale)

            // Right pan (up)
            var rightPanPath = Path()
            rightPanPath.addEllipse(in: CGRect(
                x: cx + 50 * scale,
                y: cy - 60 * scale,
                width: 80 * scale,
                height: 20 * scale
            ))
            context.fill(rightPanPath, with: .color(surface))
            context.stroke(rightPanPath, with: .color(blue.opacity(0.3)), lineWidth: 1.5 * scale)

            // Left chain
            var leftChain = Path()
            leftChain.move(to: CGPoint(x: cx - 90 * scale, y: cy - 60 * scale))
            leftChain.addLine(to: CGPoint(x: cx - 130 * scale, y: cy - 20 * scale))
            context.stroke(leftChain, with: .color(mutedBlue), lineWidth: 1.5 * scale)

            // Right chain
            var rightChain = Path()
            rightChain.move(to: CGPoint(x: cx + 90 * scale, y: cy - 40 * scale))
            rightChain.addLine(to: CGPoint(x: cx + 90 * scale, y: cy - 60 * scale))
            context.stroke(rightChain, with: .color(mutedBlue), lineWidth: 1.5 * scale)

            // Argument cards (abstract)
            let cardPositions: [(CGPoint, CGFloat, Color)] = [
                (CGPoint(x: cx - 140 * scale, y: cy + 10 * scale), 30 * scale, blue.opacity(0.3)),
                (CGPoint(x: 60 * scale, y: cy - 90 * scale), 25 * scale, blue.opacity(0.2)),
                (CGPoint(x: 200 * scale, y: cy + 40 * scale), 20 * scale, blue.opacity(0.15)),
                (CGPoint(x: 80 * scale, y: cy + 80 * scale), 18 * scale, blue.opacity(0.1)),
            ]
            for (pos, r, color) in cardPositions {
                var cardPath = Path()
                cardPath.addEllipse(in: CGRect(
                    x: pos.x - r,
                    y: pos.y - r,
                    width: r * 2,
                    height: r * 2
                ))
                context.fill(cardPath, with: .color(color))
            }

            // Dots (debaters)
            let dots: [(CGPoint, CGFloat)] = [
                (CGPoint(x: 40 * scale, y: 60 * scale), 3 * scale),
                (CGPoint(x: 260 * scale, y: 80 * scale), 2 * scale),
                (CGPoint(x: 30 * scale, y: 240 * scale), 2 * scale),
                (CGPoint(x: 270 * scale, y: 220 * scale), 3 * scale),
            ]
            for (pos, r) in dots {
                var dotPath = Path()
                dotPath.addEllipse(in: CGRect(
                    x: pos.x - r,
                    y: pos.y - r,
                    width: r * 2,
                    height: r * 2
                ))
                context.fill(dotPath, with: .color(textMuted.opacity(0.2)))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color(hex: "0F1419").ignoresSafeArea()
        GrappleEmptyIllustration(size: 200)
    }
}
