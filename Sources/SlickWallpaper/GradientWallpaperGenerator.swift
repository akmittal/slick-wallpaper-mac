import CoreGraphics
import AppKit

// MARK: - Gradient Palette

private struct GradientPair {
    let start: CGColor
    let end: CGColor
    let accent: CGColor?

    init(_ start: NSColor, _ end: NSColor, _ accent: NSColor? = nil) {
        self.start = start.cgColor
        self.end = end.cgColor
        self.accent = accent?.cgColor
    }
}

private let gradientPalette: [GradientPair] = [
    // Deep ocean
    GradientPair(NSColor(red: 0.02, green: 0.09, blue: 0.30, alpha: 1),
                 NSColor(red: 0.06, green: 0.35, blue: 0.52, alpha: 1),
                 NSColor(red: 0.14, green: 0.62, blue: 0.70, alpha: 1)),
    // Midnight aurora
    GradientPair(NSColor(red: 0.05, green: 0.05, blue: 0.18, alpha: 1),
                 NSColor(red: 0.14, green: 0.30, blue: 0.45, alpha: 1),
                 NSColor(red: 0.12, green: 0.72, blue: 0.58, alpha: 1)),
    // Warm dusk
    GradientPair(NSColor(red: 0.55, green: 0.12, blue: 0.28, alpha: 1),
                 NSColor(red: 0.95, green: 0.48, blue: 0.26, alpha: 1),
                 NSColor(red: 0.99, green: 0.80, blue: 0.40, alpha: 1)),
    // Forest mist
    GradientPair(NSColor(red: 0.04, green: 0.18, blue: 0.12, alpha: 1),
                 NSColor(red: 0.12, green: 0.42, blue: 0.28, alpha: 1),
                 NSColor(red: 0.45, green: 0.72, blue: 0.50, alpha: 1)),
    // Purple haze
    GradientPair(NSColor(red: 0.18, green: 0.05, blue: 0.30, alpha: 1),
                 NSColor(red: 0.55, green: 0.20, blue: 0.75, alpha: 1),
                 NSColor(red: 0.90, green: 0.55, blue: 0.95, alpha: 1)),
    // Slate storm
    GradientPair(NSColor(red: 0.08, green: 0.10, blue: 0.15, alpha: 1),
                 NSColor(red: 0.22, green: 0.28, blue: 0.38, alpha: 1),
                 NSColor(red: 0.45, green: 0.55, blue: 0.65, alpha: 1)),
    // Rose gold
    GradientPair(NSColor(red: 0.30, green: 0.12, blue: 0.18, alpha: 1),
                 NSColor(red: 0.75, green: 0.40, blue: 0.45, alpha: 1),
                 NSColor(red: 0.95, green: 0.75, blue: 0.70, alpha: 1)),
    // Arctic blue
    GradientPair(NSColor(red: 0.05, green: 0.15, blue: 0.28, alpha: 1),
                 NSColor(red: 0.25, green: 0.55, blue: 0.78, alpha: 1),
                 NSColor(red: 0.72, green: 0.88, blue: 0.96, alpha: 1)),
    // Obsidian ember
    GradientPair(NSColor(red: 0.06, green: 0.04, blue: 0.04, alpha: 1),
                 NSColor(red: 0.22, green: 0.08, blue: 0.04, alpha: 1),
                 NSColor(red: 0.82, green: 0.30, blue: 0.10, alpha: 1)),
    // Teal dawn
    GradientPair(NSColor(red: 0.03, green: 0.16, blue: 0.20, alpha: 1),
                 NSColor(red: 0.10, green: 0.46, blue: 0.52, alpha: 1),
                 NSColor(red: 0.55, green: 0.82, blue: 0.80, alpha: 1)),
]

// MARK: - GradientWallpaperGenerator

final class GradientWallpaperGenerator {
    static let shared = GradientWallpaperGenerator()

    /// Generates a high-resolution gradient CGImage at the given size.
    func generate(size: CGSize = targetSize()) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        let palette = gradientPalette
        let pair = palette[Int.random(in: 0..<palette.count)]

        // Draw angled linear gradient
        drawAngledGradient(in: ctx, size: size, pair: pair)

        // Add subtle noise overlay
        addNoiseOverlay(in: ctx, size: size, alpha: 0.04)

        // Add soft spotlight effect
        addSpotlight(in: ctx, size: size, pair: pair)

        return ctx.makeImage()
    }

    // MARK: - Private Helpers

    private func drawAngledGradient(in ctx: CGContext, size: CGSize, pair: GradientPair) {
        var colors: [CGColor]
        var locations: [CGFloat]

        if let accent = pair.accent {
            colors = [pair.start, pair.end, accent]
            locations = [0, 0.6, 1.0]
        } else {
            colors = [pair.start, pair.end]
            locations = [0, 1.0]
        }

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: locations
        ) else { return }

        // 135-degree angle
        let startPoint = CGPoint(x: 0, y: size.height)
        let endPoint = CGPoint(x: size.width, y: 0)
        ctx.drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
        )
    }

    private func addNoiseOverlay(in ctx: CGContext, size: CGSize, alpha: CGFloat) {
        // Draw random pixel noise for texture depth
        let pixelSize: Int = 2
        let cols = Int(size.width) / pixelSize
        let rows = Int(size.height) / pixelSize

        ctx.saveGState()
        for row in 0..<rows {
            for col in 0..<cols {
                let brightness = CGFloat.random(in: 0...1)
                ctx.setFillColor(NSColor(white: brightness, alpha: alpha * CGFloat.random(in: 0.3...1)).cgColor)
                ctx.fill(CGRect(x: col * pixelSize, y: row * pixelSize, width: pixelSize, height: pixelSize))
            }
        }
        ctx.restoreGState()
    }

    private func addSpotlight(in ctx: CGContext, size: CGSize, pair: GradientPair) {
        // Soft radial highlight at center
        let centerX = size.width * CGFloat.random(in: 0.3...0.7)
        let centerY = size.height * CGFloat.random(in: 0.3...0.7)
        let radius = max(size.width, size.height) * 0.45

        let colors: [CGColor] = [
            NSColor.white.withAlphaComponent(0.08).cgColor,
            NSColor.white.withAlphaComponent(0.0).cgColor
        ]
        let locations: [CGFloat] = [0, 1]
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: locations
        ) else { return }

        ctx.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: centerX, y: centerY), startRadius: 0,
            endCenter: CGPoint(x: centerX, y: centerY), endRadius: radius,
            options: []
        )
    }
}

// MARK: - Screen Resolution Helper

func targetSize() -> CGSize {
    // Use the primary screen's native resolution (Retina-aware)
    if let screen = NSScreen.main {
        let frame = screen.frame
        let scale = screen.backingScaleFactor
        return CGSize(width: frame.width * scale, height: frame.height * scale)
    }
    return CGSize(width: 3456, height: 2160) // default Retina fallback
}
