# Slick Wallpaper &nbsp; 🖼️✨

A gorgeous, native macOS menu-bar app that automatically generates stunning high-resolution gradient wallpapers overlayed with inspiring quotes. Built directly with Swift, SwiftUI, and AppKit—using zero third-party UI frameworks.

<div align="center">
  <img src="https://github.com/user-attachments/assets/cd1bedc5-34e8-48b4-9ce5-d5c411ee859a" width="600" alt="Slick Wallpaper Sample" />
</div>

## Features

- 🎨 **Dynamic Gradients**: Generates beautiful, Retina-ready 4K and 5K CoreGraphics gradients dynamically with 10 hand-curated color palettes, radial spotlight effects, and subtle film noise.
- 💬 **Inspiring Quotes**: Pulls from a bundled local SQLite database (`quoteitup.db`) containing tens of thousands of quotes.
- 🏷️ **Category Selection**: Choose exactly what topics inspire you (Success, Wisdom, Technology, Humor, etc.) directly from the Settings menu.
- 🕒 **Auto-Scheduling**: Set it and forget it! Wallpapers can auto-update every 1 Hour, 6 Hours, Daily, or Weekly. 
- 🪟 **Frosted Glass Typography**: Exquisite text rendering utilizing a frosted-glass backdrop pill for perfect contrast on any gradient color.
- ⚙️ **Font Customization**: Choose between classic fonts like *Georgia*, *Helvetica Neue*, *Avenir Next*, *Palatino*, and adjust your preferred font size.

## Installation & Setup

Slick Wallpaper is built natively with **Swift Package Manager (SPM)** and requires no Xcode project file. 

### Prerequisites
- macOS 13+ (Ventura or newer recommended)
- Swift 5.8+ (`swift` command line tools installed)

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/akmittal/slick-wallpaper-mac.git
   cd slick-wallpaper-mac
   ```

2. Build, bundle, and run everything with a single command:
   ```bash
   make run
   ```
   *(This script automatically compiles the release binary via SPM, creates the `.app` macOS bundle, copies the necessary SQLite database into the app's `Resources` folder, applies an ad-hoc code signature, and launches the app!).*

## Usage

Once launched, Slick Wallpaper runs entirely in the background from your macOS Menu Bar at the top right of your screen (look for the little Photo icon 🖼️).

1. Click the menu bar icon to reveal options.
2. Select **⟳ Next Wallpaper** to instantly generate a fresh background.
3. Select **⚙ Settings…** to configure your quote categories, font choices, and automated update intervals.

All generated wallpapers are cached and saved to:
`~/Library/Application Support/SlickWallpaper/`

## Architecture Highlights
- Fully decoupled **Swift Package Manager** build architecture for a macOS app native `.app` bundle.
- Uses `Combine` for reactive settings updates and scheduling.
- Asynchronous generator pipeline utilizing isolated `DispatchQueue` for flawless main-thread UI performance.
- Seamlessly bypasses known macOS `NSWorkspace` caching bugs by aggressively managing file references with UUIDs.
- *For future contributors or AI agents, see [`AGENTS.md`](AGENTS.md) for deeper architecture rules and constraints.*

## License
MIT License. Feel free to fork, modify, and build upon this project!
