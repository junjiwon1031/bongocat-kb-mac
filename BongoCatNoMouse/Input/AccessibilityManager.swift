import AppKit
import ApplicationServices

// MARK: - Accessibility Permission Manager

@MainActor
final class AccessibilityManager: ObservableObject {
    @Published var isGranted: Bool = false
    private var pollTimer: Timer?

    func checkPermission() {
        isGranted = AXIsProcessTrusted()
    }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        isGranted = trusted

        if !trusted {
            pollTimer?.invalidate()
            pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
                Task { @MainActor in
                    let granted = AXIsProcessTrusted()
                    if granted {
                        self?.isGranted = true
                        timer.invalidate()
                    }
                }
            }
        }
    }
}
