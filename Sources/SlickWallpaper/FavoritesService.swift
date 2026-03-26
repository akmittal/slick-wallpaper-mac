import Foundation
import AppKit

final class FavoritesService {
    static let shared = FavoritesService()
    
    private let favoritesDir: URL = {
        let pictures = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        let dir = pictures.appendingPathComponent("Slick Wallpaper Favorites", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()
    
    func favoriteCurrentWallpaper() {
        guard let currentURL = QuoteOverlayRenderer.shared.currentOutputURL else {
            print("[FavoritesService] No current wallpaper to save!")
            return
        }
        
        let destinationURL = favoritesDir.appendingPathComponent(currentURL.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: currentURL, to: destinationURL)
            print("[FavoritesService] Successfully saved favorite to: \(destinationURL.path)")
            
            // Provide a small visual or haptic feedback if desired
            NSSound(named: "Glass")?.play()
        } catch {
            print("[FavoritesService] Failed to save favorite: \(error)")
        }
    }
}
