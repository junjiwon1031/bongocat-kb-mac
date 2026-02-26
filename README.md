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
- **Customizable size** — Small / Medium / Large
- **Accessibility-aware** — Requests macOS Accessibility permission for global key monitoring

## Requirements

- macOS 14.0 (Sonoma) or later
- Accessibility permission (prompted on first launch)

## Installation

### Homebrew (Recommended)

```bash
brew tap junjiwon1031/tap https://github.com/junjiwon1031/homebrew-tap.git
brew install bongocat-kb-mac
bongocat-kb-mac
```

### Build from Source

```bash
git clone https://github.com/junjiwon1031/bongocat-kb-mac.git
cd bongocat-kb-mac
./build.sh
open ~/Applications/BongoCatNoMouse.app
```

Grant Accessibility permission when prompted (System Settings → Privacy & Security → Accessibility).

## Usage

Once launched, a cat icon appears in the menu bar. The Bongo Cat overlay appears in the bottom-right corner of your screen.

- **Type on your keyboard** — Watch the cat type along with you
- **Click the menu bar icon** — Access settings and quit

## Architecture

```
BongoCatNoMouse/
├── App/                  # App entry point & delegate
├── Models/               # State machine & view model
├── Views/                # SwiftUI views & sprite rendering
├── Input/                # Global event monitoring
├── Window/               # Transparent overlay panel
└── Resources/            # Sprite PNG assets
```

## Credits

- **Bongo Cat** character originally created by [@StrayRogue](https://twitter.com/StrayRogue) and [@DitzyFlama](https://twitter.com/DitzyFlama)
- Sprite assets inspired by [Bongobs-Cat-Plugin](https://github.com/a1928370421/Bongobs-Cat-Plugin) by **a1928370421**

## License

This project is licensed under the [MIT License](LICENSE).
