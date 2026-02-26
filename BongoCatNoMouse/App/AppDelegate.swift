import AppKit
import SwiftUI

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: OverlayPanel?
    private var dragOffset: NSPoint?
    private let viewModel = CatViewModel()
    private let inputMonitor = InputMonitor()
    private let accessibilityManager = AccessibilityManager()

    var sharedViewModel: CatViewModel { viewModel }
    var sharedAccessibilityManager: AccessibilityManager { accessibilityManager }

    func applicationDidFinishLaunching(_ notification: Notification) {
        accessibilityManager.requestPermission()
        setupPanel()
        setupInputMonitor()
        setupModifierMonitor()
    }

    func applicationWillTerminate(_ notification: Notification) {
        inputMonitor.stop()
    }

    // MARK: - Panel Setup

    private func setupPanel() {
        let size = viewModel.catSize.panelSize
        let panelRect = NSRect(origin: .zero, size: size)
        let overlayPanel = OverlayPanel(contentRect: panelRect)

        let hostingView = NSHostingView(
            rootView: BongoCatView(viewModel: viewModel)
        )
        hostingView.layer?.backgroundColor = .clear
        overlayPanel.contentView = hostingView

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - size.width - 40
            let y = screenFrame.minY + 20
            overlayPanel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        overlayPanel.orderFront(nil)
        self.panel = overlayPanel
    }

    // MARK: - Input Monitor

    private func setupInputMonitor() {
        inputMonitor.onKeyboard = { [weak self] keyCode in
            self?.viewModel.handleKeyboard(keyCode: keyCode)
        }
        inputMonitor.onMouseDetected = { [weak self] in
            self?.viewModel.handleMouseDetected()
        }
        inputMonitor.start()
    }

    // MARK: - Modifier Monitor

    private func setupModifierMonitor() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            let optionPressed = event.modifierFlags.contains(.option)
            self?.panel?.ignoresMouseEvents = !optionPressed
            if !optionPressed { self?.dragOffset = nil }
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            let optionPressed = event.modifierFlags.contains(.option)
            self?.panel?.ignoresMouseEvents = !optionPressed
            if !optionPressed { self?.dragOffset = nil }
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self, let panel = self.panel else { return event }
            let mouseScreen = NSEvent.mouseLocation
            self.dragOffset = NSPoint(
                x: mouseScreen.x - panel.frame.origin.x,
                y: mouseScreen.y - panel.frame.origin.y
            )
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event in
            guard let self, let panel = self.panel, let offset = self.dragOffset else { return event }
            let mouseScreen = NSEvent.mouseLocation
            let newOrigin = NSPoint(
                x: mouseScreen.x - offset.x,
                y: mouseScreen.y - offset.y
            )
            panel.setFrameOrigin(newOrigin)
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { [weak self] event in
            self?.dragOffset = nil
            return event
        }
    }

    // MARK: - Resize Panel

    func resizePanel() {
        guard let panel else { return }
        let size = viewModel.catSize.panelSize
        let origin = panel.frame.origin
        panel.setFrame(
            NSRect(origin: origin, size: size),
            display: true,
            animate: true
        )
    }
}
