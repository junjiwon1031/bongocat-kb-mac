import AppKit
import Foundation

// MARK: - Global Input Event Monitor

final class InputMonitor {
    private var keyboardMonitor: Any?
    private var mouseClickMonitor: Any?

    var onKeyboard: (@MainActor (UInt16) -> Void)?   // passes keyCode
    var onMouseDetected: (@MainActor () -> Void)?

    func start() {
        // Keyboard → typing
        keyboardMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.keyDown]
        ) { [weak self] event in
            let keyCode = event.keyCode
            guard let cb = self?.onKeyboard else { return }
            Task { @MainActor in cb(keyCode) }
        }

        // Mouse clicks → bonk
        mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        ) { [weak self] _ in
            guard let cb = self?.onMouseDetected else { return }
            Task { @MainActor in cb() }
        }
    }

    func stop() {
        if let m = keyboardMonitor { NSEvent.removeMonitor(m) }
        if let m = mouseClickMonitor { NSEvent.removeMonitor(m) }
        keyboardMonitor = nil
        mouseClickMonitor = nil
    }

    deinit {
        let k = keyboardMonitor
        let c = mouseClickMonitor
        DispatchQueue.main.async {
            if let k { NSEvent.removeMonitor(k) }
            if let c { NSEvent.removeMonitor(c) }
        }
    }
}
