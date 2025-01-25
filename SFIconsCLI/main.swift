import Foundation
import ArgumentParser
import AppKit

// Define the CLI structure
struct SFIconsCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sficons",
        abstract: "Generate SF Symbols with custom colors and export them as PNG files."
    )
    
    // Primary options

    @Option(name: .shortAndLong, help: "The name of the SF Symbol to use.")
    var symbol: String

    @Option(name: [.short, .long, .customLong("color")], help: "The foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var colour: String

    @Option(name: [.short, .long, .customLong("bgcolor")], help: "The background colour of the icon in HEX format (e.g., #469DD4).")
    var bgcolour: String
    
    enum Style: String, ExpressibleByArgument {
        case monotone, gradient, palette
    }

    @Option(name: [.long, .customShort("y")], help: "The style of the SF Symbol. Default is `monotone`, other acceptable options are `gradient` and `palette`.")
    var style: Style = .monotone
    
    @Option(name: .shortAndLong, help: "The percentage size of the SF Symbol")
    var percentforsymbol: Double
    
    // All the overlay options
    
    @Option(name: [.long, .customShort("O")], help: "Add an overlay to the bottom right corner, must pass the value for an SF Symbol, eg. `cat`.")
    var overlaysymbol: String?
    
    @Option(name: [.long, .customShort("C"), .customLong("overlaycolor")], help: "The overlay foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var overlaycolour: String = "#FFFFFF"
    
    @Option(name: [.long, .customShort("B"), .customLong("overlaybgcolor")], help: "The overlay background colour of the symbol in HEX format (e.g., #469DD4).")
    var overlaybgcolour: String = "#469DD4"
    
    // All the advanced options
    
    @Option(name: .shortAndLong, help: "Passing this flag will set a gradient on the icon.")
    var dropshadow: Bool = false
    
    @Option(name: .shortAndLong, help: "Passing this flag will set a gradient on the icon.")
    var gradient: Bool = false
    
    @Option(name: [.long, .customShort("D")], help: "Passing this flag will set a gradient on the overlay.")
    var overlaydropshadow: Bool = false
    
    @Option(name: [.long, .customShort("G")], help: "Passing this flag will set a gradient on the overlay.")
    var overlaygradient: Bool = false
    
    // Output option

    @Option(name: .shortAndLong, help: "The output file path (e.g., ~/Desktop/icon.png).")
    var output: String

    func run() throws {
        // Validate colors
        guard let foregroundColor = NSColor(hex: colour),
              let backgroundColor = NSColor(hex: bgcolour),
              let overlayColor = NSColor(hex: overlaycolour),
              let overlayBackgroundColor = NSColor(hex: overlaybgcolour)else {
            throw ValidationError("Invalid color format. Please use HEX format (e.g., #FFFFFF).")
        }

        // Generate the icon
        let image = generateSymbolImage(symbol: symbol, foregroundColor: foregroundColor, backgroundColor: backgroundColor, overlayColor: overlayColor, overlayBackgroundColor: overlayBackgroundColor, percent: percentforsymbol)
        
        // Save the icon
        let outputPath = NSString(string: output).expandingTildeInPath
        let url = URL(fileURLWithPath: outputPath)
        try saveImage(image, to: url)

        print("Icon generated and saved to \(outputPath)")
    }
}

// Helper functions
func generateSymbolImage(symbol: String, foregroundColor: NSColor, backgroundColor: NSColor, overlayColor: NSColor, overlayBackgroundColor: NSColor, percent: Double) -> NSImage {
    let totalSize: Double = 416 // 512 - 2 * 48 (border size)
    let borderSize: CGFloat = 48
    let newSize = totalSize + 2 * Double(borderSize)
    let size = NSSize(width: newSize, height: newSize)
    let cornerRadius: CGFloat = 64 // Adjust this for the desired corner radius
    
    let config = NSImage.SymbolConfiguration(pointSize: (totalSize * percent / 100), weight: .regular)
        .applying(.init(paletteColors: [foregroundColor]))
    let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
        .withSymbolConfiguration(config)
    
    let finalImage = NSImage(size: size)
    finalImage.lockFocus()
    
    // Draw the rounded square background
    let roundedRect = NSBezierPath(roundedRect: NSRect(origin: NSPoint(x: borderSize, y: borderSize), size: NSSize(width: totalSize, height: totalSize)), xRadius: cornerRadius, yRadius: cornerRadius)
    backgroundColor.setFill()
    roundedRect.fill()
    
    // Calculate the proportional size of the symbol while maintaining its aspect ratio
    let scale = totalSize * percent / 100
    let symbolSize: NSSize
    if let image = image {
        let aspectRatio = image.size.width / image.size.height
        if (aspectRatio > 1) {
            // Landscape: width is greater than height
            symbolSize = NSSize(width: scale, height: scale / aspectRatio)
        } else {
            // Portrait or square: height is greater than or equal to width
            symbolSize = NSSize(width: scale * aspectRatio, height: scale)
        }
    } else {
        // Fallback to a square if the image is nil
        symbolSize = NSSize(width: scale, height: scale)
    }

    // Center the symbol within the original image area
    let symbolOrigin = NSPoint(
        x: borderSize + (totalSize - symbolSize.width) / 2,
        y: borderSize + (totalSize - symbolSize.height) / 2
    )

    // Draw the image
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
