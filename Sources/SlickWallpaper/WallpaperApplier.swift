import AppKit
import Foundation

// MARK: - WallpaperApplier

final class WallpaperApplier {
    static let shared = WallpaperApplier()

    func apply(imageURL: URL, for targetScreen: NSScreen? = nil) throws {
        let workspace = NSWorkspace.shared
        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
            .allowClipping: true
        ]
        if let targetScreen = targetScreen {
            try workspace.setDesktopImageURL(imageURL, for: targetScreen, options: options)
        } else {
            for screen in NSScreen.screens {
                try workspace.setDesktopImageURL(imageURL, for: screen, options: options)
            }
        }
    }
}
