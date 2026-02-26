import AppKit
import SwiftUI

/// NSHostingView subclass that passes clicks through transparent pixels.
/// Opaque areas (the cat) remain interactive for dragging.
final class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }
        guard let layer = self.layer else { return super.hitTest(point) }

        let scale = window?.backingScaleFactor ?? 1.0
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel

        var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return super.hitTest(point) }

        layer.render(in: context)

        let px = Int(point.x * scale)
        let py = Int((bounds.height - point.y) * scale)

        guard px >= 0 && px < width && py >= 0 && py < height else { return nil }

        let alphaOffset = (py * bytesPerRow) + (px * bytesPerPixel) + 3
        let alpha = pixels[alphaOffset]

        return alpha < 25 ? nil : super.hitTest(point)
    }
}
