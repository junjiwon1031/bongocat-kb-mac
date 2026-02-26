import SwiftUI

// MARK: - Root View (Layer-composited Bongo Cat)
// Uses actual sprites from Bongobs-Cat-Plugin (MIT).
// All sprites are 612x354, same coordinate space — just ZStack them.
//
// Layout (from viewer's perspective):
//   Left side  = cat's RIGHT hand → rests on trackpad (always up)
//   Right side = cat's LEFT hand  → types on keyboard (up/down)

struct BongoCatView: View {
    @ObservedObject var viewModel: CatViewModel

    private let aspectRatio: CGFloat = 612.0 / 354.0

    private var isTyping: Bool {
        if case .typing = viewModel.state { return true }
        return false
    }

    private var keyIdx: Int {
        if case .typing(_, let idx) = viewModel.state { return idx }
        return 0
    }

    private var isBonked: Bool {
        viewModel.bonkPhase != nil
    }

    private var bonkPhase: BonkPhase? {
        viewModel.bonkPhase
    }

    private var showImpactEffects: Bool {
        bonkPhase == .impact || bonkPhase == .dizzy
    }

    var body: some View {
        let s = SpriteSheet.shared

        ZStack {
            // Layer 0: Background (desk + keyboard + trackpad)
            spriteLayer(s.bg)
                .zIndex(0)

            // Layer 1: Cat body (always normal cat — red X overlay handles bonk visual)
            spriteLayer(s.catbg)
                .zIndex(1)

            // Layer 2: Keyboard highlight (only when typing)
            if isTyping {
                spriteLayer(s.keyboardHighlight[keyIdx])
                    .zIndex(2)
            }

            // Layer 3: Hands (always visible)
            spriteLayer(isTyping ? s.leftDown[keyIdx] : s.leftUp)
                .zIndex(3)

            spriteLayer(s.rightWithMouse)
                .zIndex(3)

            // Bonk overlays (layers 4-6) — positioned relative to sprite frame
            if let phase = bonkPhase {
                GeometryReader { geo in
                    // Red X on cat's forehead
                    if showImpactEffects {
                        RedXOverlay()
                            .frame(width: 40, height: 40)
                            .position(x: geo.size.width * 0.65, y: geo.size.height * 0.15)
                            .zIndex(4)
                    }

                    // Hammer above cat's head
                    HammerView(phase: phase)
                        .position(x: geo.size.width * 0.60, y: geo.size.height * 0.05)
                        .zIndex(5)

                    // Impact stars at hammer position
                    ImpactEffectView(visible: showImpactEffects)
                        .position(x: geo.size.width * 0.60, y: geo.size.height * 0.05)
                        .zIndex(6)
                }
                .zIndex(4)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    private func spriteLayer(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

// MARK: - Red X Overlay (shown on cat's head during impact/dizzy)

private struct RedXOverlay: View {
    var body: some View {
        ZStack {
            // First diagonal line (top-left to bottom-right)
            Line()
                .stroke(Color.red, lineWidth: 5)
                .rotationEffect(.degrees(45))

            // Second diagonal line (top-right to bottom-left)
            Line()
                .stroke(Color.red, lineWidth: 5)
                .rotationEffect(.degrees(-45))
        }
    }
}

// MARK: - Line Shape (for X overlay)

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
