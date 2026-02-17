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

    let keyboardHighlight: [NSImage]  // 15 key highlights (0-14)

    let bonked: NSImage

    private init() {
        func load(_ name: String) -> NSImage {
            guard let url = Bundle.module.url(forResource: name, withExtension: "png", subdirectory: "Resources"),
                  let img = NSImage(contentsOf: url) else {
                fatalError("Missing sprite: \(name).png")
            }
            return img
        }

        bg    = load("bg")
        catbg = load("catbg")

        leftUp = load("lefthand_up")
        leftDown = (0..<15).map { load("lefthand_down\($0)") }

        rightUp = load("righthand_up")

        keyboardHighlight = (0..<15).map { load("keyboard_\($0)") }

        bonked = load("bongocat_hit")
    }
}
