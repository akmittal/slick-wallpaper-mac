import Foundation
import Combine

struct Logger {
    static func log(_ msg: String) {
        let path = "/tmp/slick_debug.log"
        let text = "\(Date()): \(msg)\n"
        print(text)
        if let data = text.data(using: .utf8) {
            if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: path)) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            } else {
                try? data.write(to: URL(fileURLWithPath: path))
            }
        }
    }
}

// MARK: - WallpaperPipeline

final class WallpaperPipeline {
    static let shared = WallpaperPipeline()

    func generateAndApply() {
        Logger.log("[Pipeline] generateAndApply called!")

        let settings = UserSettings.shared
        let categories = settings.enabledCategories.isEmpty ? UserSettings.allCategories : settings.enabledCategories
        let fontFamily = settings.fontFamily
        let fontSize = settings.fontSize
        
        Logger.log("[Pipeline] Dispatching to background queue...")
        DispatchQueue.global(qos: .userInitiated).async {
            self.runPipeline(categories: categories, fontFamily: fontFamily, fontSize: fontSize)
        }
    }

    private func runPipeline(categories: [String], fontFamily: String, fontSize: CGFloat) {
        Logger.log("[Pipeline] runPipeline started")
        // 1. Fetch a random quote
        guard let quote = QuoteService.shared.randomQuote(fromCategories: categories) else {
            Logger.log("[Pipeline] No quote found for categories: \(categories)")
            return
        }
        Logger.log("[Pipeline] Got quote: \"\(quote.text.prefix(40))...\" — \(quote.author)")

        // 2. Generate gradient image
        guard let gradientImage = GradientWallpaperGenerator.shared.generate() else {
            Logger.log("[Pipeline] Failed to generate gradient image")
            return
        }
        Logger.log("[Pipeline] Gradient image generated")

        // 3. Composite quote on image
        guard let outputURL = QuoteOverlayRenderer.shared.render(
            image: gradientImage,
            quote: quote,
            fontFamily: fontFamily,
            fontSize: fontSize
        ) else {
            Logger.log("[Pipeline] Failed to render quote overlay")
            return
        }
        Logger.log("[Pipeline] Overlay rendered to: \(outputURL.path)")

        // 4. Apply as wallpaper (must be main thread)
        DispatchQueue.main.async {
            Logger.log("[Pipeline] Applying wallpaper on main queue...")
            do {
                try WallpaperApplier.shared.apply(imageURL: outputURL)
                Logger.log("[Pipeline] Wallpaper applied successfully!")
            } catch {
                Logger.log("[Pipeline] Error applying wallpaper: \(error)")
            }
        }
    }
}
