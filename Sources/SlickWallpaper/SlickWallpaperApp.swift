import AppKit
import SwiftUI

// MARK: - App Entry Point

@main
struct SlickWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows by default; everything lives in the menu bar
        Settings {
            EmptyView()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var schedulerService: SchedulerService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock (belt-and-suspenders alongside Info.plist LSUIElement)
        NSApp.setActivationPolicy(.accessory)

        // Boot menu bar
        statusBarController = StatusBarController()

        // Boot scheduler (reacts to settings changes automatically)
        schedulerService = SchedulerService.shared

        // Apply wallpaper immediately on first launch
        DispatchQueue.main.async {
            WallpaperPipeline.shared.generateAndApply()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        schedulerService?.stop()
    }
}
