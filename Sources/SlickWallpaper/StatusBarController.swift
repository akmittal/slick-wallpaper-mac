import AppKit
import SwiftUI

// MARK: - StatusBarController

final class StatusBarController {
    private var statusItem: NSStatusItem!
    private var settingsWindow: NSWindow?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "photo.fill", accessibilityDescription: "Slick Wallpaper")
            button.imagePosition = .imageOnly
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        // App name header (disabled)
        let headerItem = NSMenuItem(title: "Slick Wallpaper", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        let headerFont = NSFont.boldSystemFont(ofSize: 13)
        headerItem.attributedTitle = NSAttributedString(string: "Slick Wallpaper", attributes: [.font: headerFont])
        menu.addItem(headerItem)
        menu.addItem(.separator())

        // Next Wallpaper
        let nextItem = NSMenuItem(title: "⟳  Next Wallpaper", action: #selector(nextWallpaper(_:)), keyEquivalent: "n")
        nextItem.target = self
        nextItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(nextItem)

        menu.addItem(.separator())

        // Settings
        let settingsItem = NSMenuItem(title: "⚙  Settings…", action: #selector(openSettings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.keyEquivalentModifierMask = [.command]
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func nextWallpaper(_ sender: Any?) {
        DispatchQueue.main.async {
            WallpaperPipeline.shared.generateAndApply()
        }
    }

    @objc private func openSettings(_ sender: Any?) {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings – Slick Wallpaper"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 580))
        window.minSize = NSSize(width: 420, height: 480)
        window.center()
        window.isReleasedWhenClosed = false
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
