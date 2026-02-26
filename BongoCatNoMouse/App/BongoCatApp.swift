import SwiftUI

// MARK: - Main App Entry Point

@main
struct BongoCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("BongoCat", systemImage: "cat.fill") {
            MenuBarView(
                viewModel: appDelegate.sharedViewModel,
                accessibilityManager: appDelegate.sharedAccessibilityManager,
                onResize: { [weak appDelegate] in appDelegate?.resizePanel() }
            )
        }
        .menuBarExtraStyle(.window)
    }
}
