# Agent Context & Guidelines for Slick Wallpaper

Welcome, fellow AI Assistant! This document provides the necessary context and technical constraints for working on the **Slick Wallpaper** macOS repository.

## Overview
Slick Wallpaper is a native macOS menu-bar application written in Swift using SwiftUI and AppKit. It generates high-resolution gradient wallpapers, overlays inspirational quotes, and automatically applies them to the user's desktop on a scheduled basis.

## Build System & Architecture
- **No Xcode Project**: This app is built entirely using **Swift Package Manager (SPM)** and a custom `Makefile`. Do not attempt to use `xcodebuild` or look for an `.xcodeproj` file.
- **Makefile Targets**:
  - `make build` -> Compiles the source using SPM (`swift build -c release`).
  - `make bundle` -> Packages the compiled binary and resources (like `quoteitup.db`) into a proper `SlickWallpaper.app` macOS bundle.
  - `make sign` -> Applies an ad-hoc code signature to the bundle.
  - `make run` -> Executes `build`, `bundle`, `sign`, and then launches the `.app`.
- **UI Paradigm**: The app operates exclusively from the macOS Menu Bar (`LSUIElement = YES`). There is no Dock icon or main app window, though there is a SwiftUI Settings window (`SettingsView`).

## Key Components
- `WallpaperPipeline`: Orchestrates the entire generation and application process asynchronously.
- `GradientWallpaperGenerator`: Generates the gorgeous Core Graphics gradients and noise textures.
- `QuoteOverlayRenderer`: Composites text overlays with frosted glass effects onto the images.
- `QuoteService`: Interacts with a local SQLite database (`quoteitup.db`) via `SQLite.swift` to fetch random quotes based on categories.
- `SchedulerService`: A Combine-powered timer that triggers wallpaper updates in the background.

## ⚠️ Critical Constraints & Gotchas
1. **macOS Wallpaper Caching Bug**:
   You **MUST** generate unique filenames for every wallpaper update (e.g., `wallpaper_<UUID>.jpg`). If you attempt to overwrite a steady file path (like `current.jpg`) and call `NSWorkspace.shared.setDesktopImageURL`, macOS will silently cache the file URL and refuse to update the desktop image. (See `QuoteOverlayRenderer.generateNewOutputURL()`).
2. **Concurrency Mismatches**:
   Avoid `@MainActor` class-level isolated objects being called directly from `@objc` selectors (like Menu Items). Swift concurrency isolation at runtime will silently drop the calls if the threads mismatch. Rely on `DispatchQueue.global` and `DispatchQueue.main.async` for safe bridging between purely async operations and AppKit's older threading logic.
3. **Database Lookups**:
   The `quoteitup.db` file behaves differently in development (SPM `.build/` deep paths) vs production (`.app/Contents/Resources`). `QuoteService.findDatabaseURL()` abstracts this lookup logic.

## Workflow
If you are asked to implement a new feature:
1. Make your changes in the `Sources/` directory.
2. Build and run using the terminal command: `cd /Users/akmittal/projects/slick-wallpaper-mac && make run`.
3. Check system logs for `[Pipeline]` output if the wallpaper engine fails: `log show --predicate 'process == "SlickWallpaper"' --last 1m`
4. Use standard Swift best practices and strict type safety.
