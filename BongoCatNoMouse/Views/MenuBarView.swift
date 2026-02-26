import SwiftUI

// MARK: - Menu Bar View

struct MenuBarView: View {
    @ObservedObject var viewModel: CatViewModel
    @ObservedObject var accessibilityManager: AccessibilityManager
    var onResize: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Controls section
            VStack(alignment: .leading, spacing: 6) {
                Text("Controls")
                    .font(.caption)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Text("⌥ Option + Drag")
                        .font(.caption)
                    Spacer()
                    Text("Move cat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 12) {
                    Text("Mouse Click")
                        .font(.caption)
                    Spacer()
                    Text("Bonk!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)

            Divider()

            // Settings section
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(.caption)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Bonk Cooldown")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("\(String(format: "%.1f", viewModel.bonkCooldown))s between bonks")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.bonkCooldown, in: 1...10, step: 0.5)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Cat Size")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Picker("", selection: $viewModel.catSize) {
                        ForEach(CatSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.catSize) { _, _ in
                        onResize()
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.vertical, 4)

            Divider()

            // Accessibility status
            HStack(spacing: 8) {
                if accessibilityManager.isGranted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Accessibility Granted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "xmark.circle")
                        .font(.caption)
                        .foregroundColor(.red)
                    Button("Grant Access") {
                        accessibilityManager.requestPermission()
                    }
                    .font(.caption)
                }
            }
            .padding(.vertical, 4)

            Divider()

            Button("Quit (⌘Q)") {
                NSApplication.shared.terminate(nil)
            }
            .font(.caption)
            .keyboardShortcut("q")
        }
        .padding(8)
        .frame(width: 220)
    }
}
