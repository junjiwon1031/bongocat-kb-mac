import SwiftUI

// MARK: - Menu Bar View

struct MenuBarView: View {
    @ObservedObject var viewModel: CatViewModel
    @ObservedObject var accessibilityManager: AccessibilityManager
    var onResize: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Accessibility status
            if !accessibilityManager.isGranted {
                Button("Grant Accessibility Permission") {
                    accessibilityManager.requestPermission()
                }
            } else {
                Text("Accessibility Granted")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Divider()

            // Bonk cooldown slider
            VStack(alignment: .leading) {
                Text("Bonk Cooldown: \(String(format: "%.1f", viewModel.bonkCooldown))s")
                    .font(.caption)
                Slider(value: $viewModel.bonkCooldown, in: 1...10, step: 0.5)
                    .frame(width: 180)
            }
            .padding(.vertical, 4)

            Divider()

            // Cat size picker
            VStack(alignment: .leading) {
                Text("Cat Size")
                    .font(.caption)
                Picker("", selection: $viewModel.catSize) {
                    ForEach(CatSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                .onChange(of: viewModel.catSize) { _, _ in
                    onResize()
                }
            }
            .padding(.vertical, 4)

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(8)
    }
}
