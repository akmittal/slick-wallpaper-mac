import AppKit

let pngURL = URL(fileURLWithPath: "logo.png")
guard let pngData = try? Data(contentsOf: pngURL),
      let nsImage = NSImage(data: pngData) else {
    print("Failed to read logo.png")
    exit(1)
}

let iconsetURL = URL(fileURLWithPath: "AppIcon.iconset")
try? FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let sizes = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

for (size, scale) in sizes {
    let px = size * scale
    let fileName = scale == 1 ? "icon_\(size)x\(size).png" : "icon_\(size)x\(size)@\(scale)x.png"
    
    let targetSize = CGSize(width: px, height: px)
    let newImage = NSImage(size: targetSize)
    newImage.lockFocus()
    
    let context = NSGraphicsContext.current!.cgContext
    context.interpolationQuality = .high
    
    nsImage.draw(in: NSRect(origin: .zero, size: targetSize),
                 from: NSRect(origin: .zero, size: nsImage.size),
                 operation: .sourceOver,
                 fraction: 1.0)
    
    newImage.unlockFocus()
    
    guard let tiffData = newImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let outputPngData = bitmap.representation(using: .png, properties: [:]) else {
        continue
    }
    
    let fileURL = iconsetURL.appendingPathComponent(fileName)
    try? outputPngData.write(to: fileURL)
}

print("Running iconutil...")
