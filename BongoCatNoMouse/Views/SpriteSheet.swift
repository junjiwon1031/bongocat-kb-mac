import AppKit
import SwiftUI

// MARK: - Sprite Loader
// Loads layered sprites from Bongobs-Cat-Plugin (MIT license).
// All sprites are 612x354, same coordinate space — just stack them.

@MainActor
final class SpriteSheet {
    static let shared = SpriteSheet()

    let bg: NSImage
    let catbg: NSImage

    let leftUp: NSImage
    let leftDown: [NSImage]      // 15 key positions (0-14)

    let rightUp: NSImage
    let rightWithMouse: NSImage   // default right hand on mousepad

    let keyboardHighlight: [NSImage]  // 15 key highlights (0-14)

    let bonked: NSImage

    private static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }

    private init() {
        func load(_ name: String) -> NSImage {
            // Try SwiftPM layout (Resources subdirectory) first, then Xcode layout (flat Resources folder)
            let bundle = SpriteSheet.resourceBundle
            if let url = bundle.url(forResource: name, withExtension: "png", subdirectory: "Resources"),
               let img = NSImage(contentsOf: url) {
                return img
            }
            if let url = bundle.url(forResource: name, withExtension: "png"),
               let img = NSImage(contentsOf: url) {
                return img
            }
            fatalError("Missing sprite: \(name).png")
        }

        bg    = load("bg")
        catbg = load("catbg")

        leftUp = load("lefthand_up")
        leftDown = (0..<15).map { load("lefthand_down\($0)") }

        rightUp = load("righthand_up")
        rightWithMouse = load("righthand_with_mouse_4")

        keyboardHighlight = (0..<15).map { load("keyboard_\($0)") }

        bonked = load("bongocat_hit")
    }
}
