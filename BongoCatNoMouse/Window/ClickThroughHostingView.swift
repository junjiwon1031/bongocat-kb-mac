import AppKit
import SwiftUI

/// NSHostingView subclass that passes clicks through transparent pixels.
/// Opaque areas (the cat) remain interactive for dragging.
final class ClickThroughHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }

        guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return super.hitTest(point)
        }
        cacheDisplay(in: bounds, to: bitmapRep)

        let flippedY = Int(bounds.height - point.y)
        let x = Int(point.x)

        guard let color = bitmapRep.colorAt(x: x, y: flippedY) else {
            return nil
        }

        // Transparent pixel → pass click through
        if color.alphaComponent < 0.1 {
            return nil
        }

        return super.hitTest(point)
    }
}
