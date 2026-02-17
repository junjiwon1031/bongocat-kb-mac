import AppKit
import Foundation

// MARK: - Global Input Event Monitor

final class InputMonitor {
    private var keyboardMonitor: Any?
    private var mouseClickMonitor: Any?
    private var mouseMoveMonitor: Any?
    private var scrollMonitor: Any?

    private let jitterFilter = MouseJitterFilter()

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

        // Mouse move → bonk (with jitter filter)
        mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]
        ) { [weak self] event in
            guard let self else { return }
            let point = event.locationInWindow
            let isSignificant = self.jitterFilter.feed(point: point)
            if isSignificant {
                self.jitterFilter.reset()
                guard let cb = self.onMouseDetected else { return }
                Task { @MainActor in cb() }
            }
        }

        // Scroll → bonk
        scrollMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.scrollWheel]
        ) { [weak self] _ in
            guard let cb = self?.onMouseDetected else { return }
            Task { @MainActor in cb() }
        }
    }

    func stop() {
        if let m = keyboardMonitor { NSEvent.removeMonitor(m) }
        if let m = mouseClickMonitor { NSEvent.removeMonitor(m) }
        if let m = mouseMoveMonitor { NSEvent.removeMonitor(m) }
        if let m = scrollMonitor { NSEvent.removeMonitor(m) }
        keyboardMonitor = nil
        mouseClickMonitor = nil
        mouseMoveMonitor = nil
        scrollMonitor = nil
    }

    deinit {
        let k = keyboardMonitor
        let c = mouseClickMonitor
        let m = mouseMoveMonitor
        let s = scrollMonitor
        DispatchQueue.main.async {
            if let k { NSEvent.removeMonitor(k) }
            if let c { NSEvent.removeMonitor(c) }
            if let m { NSEvent.removeMonitor(m) }
            if let s { NSEvent.removeMonitor(s) }
        }
    }
}
