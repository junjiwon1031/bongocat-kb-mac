import SwiftUI
import Combine

// MARK: - Cat ViewModel

@MainActor
final class CatViewModel: ObservableObject {
    @Published var state: CatState = .idle
    @Published var bonkPhase: BonkPhase? = nil

    // Settings
    @AppStorage("bonkCooldown") var bonkCooldown: Double = 3.0
    @AppStorage("catSize") var catSize: CatSize = .medium

    private var idleTimer: Task<Void, Never>?
    private var bonkTask: Task<Void, Never>?
    private var pressCounter = 0
    private var lastKeyIdx = -1

    // macOS keyCodes: space=49, backspace=51, enter=36, return=76
    private static let wideKeys: Set<UInt16> = [49, 51, 36, 76]
    private static let normalKeyIndices = Array(0..<15).filter { $0 != 10 }  // 0-9, 11-14

    // MARK: - Keyboard Input

    func handleKeyboard(keyCode: UInt16) {
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

    // MARK: - Mouse Detected

    func handleMouseDetected() {
        // Guard: prevent re-triggering during bonk animation
        guard bonkPhase == nil else { return }

        // Run the bonk phase sequence
        bonkTask = Task {
            // Phase 1: Hammer appearing
            bonkPhase = .hammerAppearing
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }

            // Phase 2: Hammer swinging
            bonkPhase = .hammerSwinging
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled else { return }

            // Phase 3: Impact
            bonkPhase = .impact
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            // Phase 4: Dizzy
            bonkPhase = .dizzy
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }

            // Phase 5: Recovering
            bonkPhase = .recovering
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }

            // End bonk sequence
            bonkPhase = nil
        }
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
