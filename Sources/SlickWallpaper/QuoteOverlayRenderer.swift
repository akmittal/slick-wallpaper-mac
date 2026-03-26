import CoreGraphics
import CoreText
import AppKit
import Foundation
import UniformTypeIdentifiers

// MARK: - QuoteOverlayRenderer

final class QuoteOverlayRenderer {
    static let shared = QuoteOverlayRenderer()

    private let outputDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("SlickWallpaper", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    var currentOutputURL: URL?

    func generateNewOutputURL() -> URL {
        // Cleanup old wallpapers
        if let files = try? FileManager.default.contentsOfDirectory(at: outputDir, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "jpg" {
                try? FileManager.default.removeItem(at: file)
            }
        }
        let url = outputDir.appendingPathComponent("wallpaper_\(UUID().uuidString).jpg")
        currentOutputURL = url
        return url
    }

    /// Composites a quote onto the gradient image and saves it as JPEG.
    func render(image: CGImage, quote: Quote, fontFamily: String, fontSize: CGFloat) -> URL? {
        let size = CGSize(width: image.width, height: image.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let ctx = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Draw background gradient
        ctx.draw(image, in: CGRect(origin: .zero, size: size))

        // --- Layout constants ---
        let maxTextWidth: CGFloat = size.width * 0.68
        let centerX: CGFloat = size.width / 2

        // Resolve font
        let resolvedQuoteFont = resolveFont(family: fontFamily, size: fontSize * (size.width / 1920))
        let resolvedAuthorFont = resolveFont(family: fontFamily, size: fontSize * 0.42 * (size.width / 1920), italic: true)

        // Build attributed strings
        let quoteAS = makeAttributedString(
            text: "\u{201C}\(quote.text)\u{201D}",
            font: resolvedQuoteFont,
            color: NSColor.white,
            tracking: 0.5,
            lineSpacing: fontSize * 0.3 * (size.width / 1920)
        )
        let authorAS = makeAttributedString(
            text: "— \(quote.author)",
            font: resolvedAuthorFont,
            color: NSColor.white.withAlphaComponent(0.75),
            tracking: 1.5,
            lineSpacing: 0
        )

        // Measure text
        let quoteFrame = measureText(quoteAS, maxWidth: maxTextWidth)
        let authorFrame = measureText(authorAS, maxWidth: maxTextWidth)

        let gap: CGFloat = fontSize * 0.5 * (size.width / 1920)
        let totalTextHeight = quoteFrame.height + gap + authorFrame.height
        let blockPadX: CGFloat = size.width * 0.055
        let blockPadY: CGFloat = size.height * 0.042

        let blockWidth = max(quoteFrame.width, authorFrame.width) + blockPadX * 2
        let blockHeight = totalTextHeight + blockPadY * 2

        let placement = UserSettings.shared.quotePlacement
        let marginX = size.width * 0.06
        let marginY = size.height * 0.06

        let blockX: CGFloat
        let blockY: CGFloat

        switch placement {
        case .center:
            blockX = centerX - blockWidth / 2
            blockY = (size.height - blockHeight) / 2
        case .bottomLeft:
            blockX = marginX
            blockY = marginY
        case .topRight:
            blockX = size.width - blockWidth - marginX
            blockY = size.height - blockHeight - marginY
        }

        let opacity = UserSettings.shared.backdropOpacity
        if opacity > 0.0 {
            // Draw frosted-glass backdrop pill
            drawBackdrop(
                in: ctx,
                rect: CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight),
                cornerRadius: size.width * 0.018,
                opacity: opacity
            )
        }

        // Draw quote text
        let quoteY = blockY + blockPadY + authorFrame.height + gap
        drawText(
            quoteAS,
            in: ctx,
            origin: CGPoint(x: blockX + blockPadX + (max(quoteFrame.width, authorFrame.width) - quoteFrame.width) / 2, y: quoteY),
            maxWidth: maxTextWidth
        )

        // Draw author text
        let authorY = blockY + blockPadY
        drawText(
            authorAS,
            in: ctx,
            origin: CGPoint(x: blockX + blockPadX + (max(quoteFrame.width, authorFrame.width) - authorFrame.width) / 2, y: authorY),
            maxWidth: maxTextWidth
        )

        guard let finalImage = ctx.makeImage() else { return nil }

        // Save as JPEG to a unique file to prevent macOS caching
        let newURL = generateNewOutputURL()
        return saveJPEG(finalImage, to: newURL)
    }

    // MARK: - Helpers

    private func resolveFont(family: String, size: CGFloat, italic: Bool = false) -> CTFont {
        let traits: [NSFontDescriptor.TraitKey: Any] = italic
            ? [.symbolic: NSFontDescriptor.SymbolicTraits.italic.rawValue]
            : [:]
        let descriptor = NSFontDescriptor(name: family, size: size).addingAttributes([.traits: traits])
        let nsFont = NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size)
        return nsFont as CTFont
    }

    private func makeAttributedString(
        text: String,
        font: CTFont,
        color: NSColor,
        tracking: CGFloat,
        lineSpacing: CGFloat
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = lineSpacing

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .kern: tracking,
            .paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: text, attributes: attrs)
    }

    private func measureText(_ attrStr: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        let boundingRect = attrStr.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }

    private func drawText(_ attrStr: NSAttributedString, in ctx: CGContext, origin: CGPoint, maxWidth: CGFloat) {
        // Use NSAttributedString drawing via a temporary NSImage for crisp text
        let size = measureText(attrStr, maxWidth: maxWidth)
        let image = NSImage(size: size, flipped: false) { rect in
            attrStr.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading])
            return true
        }
        if let cgImg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ctx.draw(cgImg, in: CGRect(origin: origin, size: size))
        }
    }

    private func drawBackdrop(in ctx: CGContext, rect: CGRect, cornerRadius: CGFloat, opacity: Double) {
        ctx.saveGState()
        // Dark frosted pill
        let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        ctx.addPath(path)
        ctx.setFillColor(NSColor.black.withAlphaComponent(CGFloat(opacity)).cgColor)
        ctx.fillPath()

        // Subtle white border
        ctx.addPath(path)
        ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.12).cgColor)
        ctx.setLineWidth(rect.width * 0.002)
        ctx.strokePath()
        ctx.restoreGState()
    }

    private func saveJPEG(_ image: CGImage, to url: URL) -> URL? {
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 0.95]
        CGImageDestinationAddImage(dest, image, options as CFDictionary)
        return CGImageDestinationFinalize(dest) ? url : nil
    }
}
