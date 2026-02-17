import SwiftUI
import Combine

// MARK: - Cat ViewModel

@MainActor
final class CatViewModel: ObservableObject {
    @Published var state: CatState = .idle

    // Settings
    @AppStorage("bonkCooldown") var bonkCooldown: Double = 3.0
    @AppStorage("catSize") var catSize: CatSize = .medium

    private var idleTimer: Task<Void, Never>?
    private var pressCounter = 0
    private var lastKeyIdx = -1

    // macOS keyCodes: space=49, backspace=51, enter=36, return=76
    private static let wideKeys: Set<UInt16> = [49, 51, 36, 76]
    private static let normalKeyIndices = Array(0..<15).filter { $0 != 10 }  // 0-9, 11-14

    // MARK: - Keyboard Input

    func handleKeyboard(keyCode: UInt16) {
        if case .bonked = state { return }

        idleTimer?.cancel()
        pressCounter += 1

        let keyIdx: Int
        if Self.wideKeys.contains(keyCode) {
            keyIdx = 10  // spacebar area
        } else {
            // Random from non-space keys, avoid repeating same position
            var pick = Self.normalKeyIndices.randomElement()!
            if pick == lastKeyIdx {
                pick = Self.normalKeyIndices.filter { $0 != lastKeyIdx }.randomElement()!
            }
            keyIdx = pick
        }
        lastKeyIdx = keyIdx

        state = .typing(pressId: pressCounter, keyIdx: keyIdx)

        idleTimer = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            state = .idle
        }
    }

    // MARK: - Mouse Detected (TODO: bonk with custom sprites)

    func handleMouseDetected() {
        // Disabled until custom hammer sprites are ready
    }
}

// MARK: - Cat Size

enum CatSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    var scale: CGFloat {
        switch self {
        case .small:  return 0.7
        case .medium: return 1.0
        case .large:  return 1.3
        }
    }

    // 612:354 aspect ratio
    var panelSize: NSSize {
        switch self {
        case .small:  return NSSize(width: 245, height: 142)
        case .medium: return NSSize(width: 367, height: 212)
        case .large:  return NSSize(width: 490, height: 283)
        }
    }
}
