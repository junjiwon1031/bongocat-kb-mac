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

    var body: some View {
        let s = SpriteSheet.shared

        ZStack {
            // Layer 1: Background (desk + keyboard + trackpad)
            spriteLayer(s.bg)
                .zIndex(0)

            // Layer 2: Cat body
            spriteLayer(s.catbg)
                .zIndex(1)

            // Layer 3: Keyboard highlight (only when typing)
            if isTyping {
                spriteLayer(s.keyboardHighlight[keyIdx])
                    .zIndex(2)
            }

            // Layer 4: Left hand (screen right) — keyboard hand
            spriteLayer(isTyping ? s.leftDown[keyIdx] : s.leftUp)
                .zIndex(3)

            // Layer 5: Right hand (screen left) — trackpad hand, always resting
            spriteLayer(s.rightUp)
                .zIndex(3)
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
