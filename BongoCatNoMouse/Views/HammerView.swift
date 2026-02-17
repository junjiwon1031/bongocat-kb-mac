import SwiftUI

// MARK: - Hammer View (Layer 3)
// Red rubber head + gold handle. Swings down to bonk the cat.

struct HammerView: View {
    let phase: BonkPhase

    private var rotation: Double {
        switch phase {
        case .hammerAppearing: return -80
        case .hammerSwinging:  return -45
        case .impact:          return 25
        case .dizzy:           return 25
        case .recovering:      return -80
        }
    }

    private var opacity: Double {
        switch phase {
        case .hammerAppearing: return 1.0
        case .hammerSwinging:  return 1.0
        case .impact:          return 1.0
        case .dizzy:           return 0.6
        case .recovering:      return 0.0
        }
    }

    private var yOffset: CGFloat {
        switch phase {
        case .hammerAppearing: return -30
        case .hammerSwinging:  return 0
        case .impact:          return 0
        case .dizzy:           return 0
        case .recovering:      return -30
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            hammerHead
            hammerHandle
        }
        .rotationEffect(.degrees(rotation), anchor: .bottom)
        .offset(y: yOffset)
        .opacity(opacity)
        .animation(.easeInOut(duration: 0.15), value: phase)
    }

    // MARK: - Hammer Head

    private var hammerHead: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.red, Color(red: 0.85, green: 0.1, blue: 0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 44, height: 30)

            // Ridges (toy hammer look)
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.7, green: 0.05, blue: 0.05))
                        .frame(width: 38, height: 2)
                }
            }

            // Highlight
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 8)
                .offset(y: -6)
        }
    }

    // MARK: - Handle

    private var hammerHandle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.65, blue: 0.2),
                            Color(red: 0.7, green: 0.5, blue: 0.15)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 10, height: 45)

            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.6, green: 0.4, blue: 0.1))
                .frame(width: 6, height: 45)
        }
    }
}

// MARK: - Impact Stars (shown on bonk)

struct ImpactEffectView: View {
    let visible: Bool

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                StarShape()
                    .fill(Color.yellow)
                    .frame(width: 14, height: 14)
                    .offset(
                        x: CGFloat([20, -18, 25, -22, 0][i]),
                        y: CGFloat([-18, -22, 10, 14, -30][i])
                    )
                    .rotationEffect(.degrees(Double(i) * 25))
            }
        }
        .opacity(visible ? 1 : 0)
        .scaleEffect(visible ? 1.2 : 0.3)
        .animation(.easeOut(duration: 0.15), value: visible)
    }
}

// MARK: - Star Shape

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.35
        let points = 4

        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let pt = CGPoint(
                x: cx + CGFloat(cos(angle)) * r,
                y: cy + CGFloat(sin(angle)) * r
            )
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}
