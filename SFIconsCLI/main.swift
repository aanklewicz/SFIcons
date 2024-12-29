import Foundation
import ArgumentParser
import AppKit

// Define the CLI structure
struct SFIconsCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Generate SF Symbols with custom colors and export them as PNG files."
    )

    @Option(name: .shortAndLong, help: "The name of the SF Symbol to use.")
    var symbol: String

    @Option(name: [.short, .long, .customLong("color")], help: "The foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var colour: String

    @Option(name: [.short, .long, .customLong("bgcolor")], help: "The background colour of the icon in HEX format (e.g., #1D75D2).")
    var bgcolour: String

    @Option(name: .shortAndLong, help: "The output file path (e.g., ~/Desktop/icon.png).")
    var output: String

    func run() throws {
        // Validate colors
        guard let foregroundColor = NSColor(hex: colour),
              let backgroundColor = NSColor(hex: bgcolour) else {
            throw ValidationError("Invalid color format. Please use HEX format (e.g., #FFFFFF).")
        }

        // Generate the icon
        let image = generateSymbolImage(symbol: symbol, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
        
        // Save the icon
        let outputPath = NSString(string: output).expandingTildeInPath
        let url = URL(fileURLWithPath: outputPath)
        try saveImage(image, to: url)

        print("Icon generated and saved to \(outputPath)")
    }
}

// Helper functions
func generateSymbolImage(symbol: String, foregroundColor: NSColor, backgroundColor: NSColor) -> NSImage {
    let size = NSSize(width: 256, height: 256)
    let cornerRadius: CGFloat = 64 // Adjust this for the desired corner radius
    
    let config = NSImage.SymbolConfiguration(pointSize: 128, weight: .regular)
        .applying(.init(paletteColors: [foregroundColor]))
    let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
        .withSymbolConfiguration(config)
    
    let finalImage = NSImage(size: size)
    finalImage.lockFocus()
    
    // Draw the rounded square background
    let roundedRect = NSBezierPath(roundedRect: NSRect(origin: .zero, size: size), xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    roundedRect.fill()
    
    // Draw the SF Symbol centered on the background
    let symbolSize = NSSize(width: 128, height: 128)
    let symbolOrigin = NSPoint(x: (size.width - symbolSize.width) / 2, y: (size.height - symbolSize.height) / 2)
    image?.draw(in: NSRect(origin: symbolOrigin, size: symbolSize))
    
    finalImage.unlockFocus()
    
    return finalImage
}

func saveImage(_ image: NSImage, to url: URL) throws {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SFIconsCLI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate PNG data."])
    }
    try pngData.write(to: url)
}

// NSColor extension for HEX conversion
extension NSColor {
    convenience init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6,
              let rgb = Int(hexString, radix: 16) else { return nil }
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
            green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
            blue: CGFloat(rgb & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

SFIconsCLI.main()
