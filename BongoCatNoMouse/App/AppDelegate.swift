import AppKit
import SwiftUI

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: OverlayPanel?
    private let viewModel = CatViewModel()
    private let inputMonitor = InputMonitor()
    private let accessibilityManager = AccessibilityManager()

    var sharedViewModel: CatViewModel { viewModel }
    var sharedAccessibilityManager: AccessibilityManager { accessibilityManager }

    func applicationDidFinishLaunching(_ notification: Notification) {
        accessibilityManager.requestPermission()
        setupPanel()
        setupInputMonitor()
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
