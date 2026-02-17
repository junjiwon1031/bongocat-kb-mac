import Foundation

// MARK: - Cat State Machine

enum CatState: Equatable {
    case idle
    case typing(pressId: Int, keyIdx: Int)   // unique id + sprite index (0-14)
    case bonked(phase: BonkPhase)
}

enum BonkPhase: Equatable {
    case hammerAppearing
    case hammerSwinging
    case impact
    case dizzy
    case recovering
}
