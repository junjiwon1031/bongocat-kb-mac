# BongoCatNoMouse

A macOS menu bar app that displays an animated Bongo Cat overlay on your screen. The cat reacts to your keyboard input in real time — typing along with you as you work.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Real-time keyboard tracking** — The cat types along as you press keys
- **15 key positions** — Different hand and keyboard highlight animations for variety
- **Special key handling** — Space, Backspace, and Enter trigger wide-key animations
- **Always-on-top overlay** — Transparent, borderless panel that stays visible on all Spaces
- **Menu bar app** — Lives in the menu bar with no Dock icon
- **Customizable settings**
  - Bonk cooldown (1–10 seconds)
  - Cat size (Small / Medium / Large)
- **Accessibility-aware** — Requests macOS Accessibility permission for global key monitoring

## Requirements

- macOS 14.0 (Sonoma) or later
- Accessibility permission (prompted on first launch)

## Installation

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/bongocat-nomouse.git
   cd bongocat-nomouse
   ```

2. Open in Xcode:
   ```bash
   open BongoCatNoMouse.xcodeproj
   ```

3. Build and run (`Cmd + R`)

4. Grant Accessibility permission when prompted (System Settings → Privacy & Security → Accessibility)

## Usage

Once launched, a cat icon appears in the menu bar. The Bongo Cat overlay appears in the top-right corner of your screen.

- **Type on your keyboard** — Watch the cat type along with you
- **Click the menu bar icon** — Access settings
- **Drag the overlay** — Reposition the cat anywhere on screen

### Settings

| Setting | Description | Range |
|---------|-------------|-------|
| Bonk Cooldown | Delay between bonk animations | 1–10 seconds |
| Cat Size | Overlay size | Small / Medium / Large |

## Architecture

```
BongoCatNoMouse/
├── App/                  # App entry point & delegate
├── Models/               # State machine & view model
├── Views/                # SwiftUI views & sprite rendering
├── Input/                # Global event monitoring
├── Window/               # Transparent overlay panel
└── Resources/            # 65 sprite PNG assets
```

- **MVVM** pattern with `CatViewModel` as the central state manager
- **State machine** (`CatState`) with `.idle`, `.typing`, and `.bonked` states
- **Sprite composition** — 5-layer ZStack (background → cat body → keyboard highlight → left hand → right hand)
- **Global event tap** via `NSEvent.addGlobalMonitorForEvents` for keyboard capture

## Credits

- **Bongo Cat** character originally created by [@StrayRogue](https://twitter.com/StrayRogue) and [@DitzyFlama](https://twitter.com/DitzyFlama)
- Sprite assets inspired by [Bongobs-Cat-Plugin](https://github.com/a1928370421/Bongobs-Cat-Plugin) by **a1928370421**

## License

This project is licensed under the [MIT License](LICENSE).