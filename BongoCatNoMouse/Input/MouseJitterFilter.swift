import Foundation

// MARK: - Mouse Jitter Filter
// Ignores tiny mouse movements (< threshold px in a time window)
// so accidental desk vibrations don't trigger bonk.

final class MouseJitterFilter {
    private let windowDuration: TimeInterval = 0.3
    private let distanceThreshold: CGFloat = 15.0

    private var cumulativeDistance: CGFloat = 0
    private var windowStart: Date = .distantPast
    private var lastPoint: CGPoint?

    /// Returns `true` if the movement is significant (not jitter).
    func feed(point: CGPoint) -> Bool {
        let now = Date()

        if now.timeIntervalSince(windowStart) > windowDuration {
            cumulativeDistance = 0
            windowStart = now
            lastPoint = point
            return false
        }

        if let last = lastPoint {
            let dx = point.x - last.x
            let dy = point.y - last.y
            cumulativeDistance += sqrt(dx * dx + dy * dy)
        }
        lastPoint = point

        return cumulativeDistance >= distanceThreshold
    }

    func reset() {
        cumulativeDistance = 0
        windowStart = .distantPast
        lastPoint = nil
    }
}
