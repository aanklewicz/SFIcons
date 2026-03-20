import Foundation
import ArgumentParser
import AppKit
import SwiftUI

// Define the CLI structure
struct SFIconsCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sficons",
        abstract: "Generate SF Symbols with custom colors and export them as PNG files."
    )

    // Primary options

    @Option(name: .shortAndLong, help: "The name of the SF Symbol to use.")
    var symbol: String

    @Option(name: [.short, .customLong("colour"), .customLong("color")], help: "The foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var colour: String

    @Option(name: [.customShort("S"), .customLong("secondarycolour"), .customLong("secondarycolor")], help: "The secondary foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var secondarycolour: String?

    @Option(name: [.short, .customLong("bgcolour"), .customLong("bgcolor")], help: "The background colour of the icon in HEX format (e.g., #469DD4).")
    var bgcolour: String

    enum Style: String, ExpressibleByArgument {
        case monotone, gradient, palette
    }

    @Option(name: [.long, .customShort("y")], help: "The style of the SF Symbol. Default is `monotone`, other acceptable options are `gradient` and `palette`.")
    var style: String = "monotone"

    @Option(name: .shortAndLong, help: "The percentage size of the SF Symbol.")
    var percentforsymbol: Double

    // All the overlay options

    @Option(name: [.customLong("overlaysymbol"), .customShort("O")], help: "Add an overlay, must pass the value for an SF Symbol, e.g. `cat`.")
    var overlaysymbol: String?

    @Option(name: [.customShort("C"), .customLong("overlaycolour"), .customLong("overlaycolor")], help: "The overlay foreground colour of the symbol in HEX format (e.g., #FFFFFF).")
    var overlaycolour: String = "#FFFFFF"

    @Option(name: [.customShort("B"), .customLong("overlaybgcolour"), .customLong("overlaybgcolor")], help: "The overlay background colour of the symbol in HEX format (e.g., #469DD4).")
    var overlaybgcolour: String = "#469DD4"

    @Option(name: [.customShort("P"), .customLong("overlayposition")], help: "The corner position for the overlay. Options: `bottomtrailing` (default), `bottomleading`, `toptrailing`, `topleading`.")
    var overlayposition: String = "bottomtrailing"

    // All the advanced options

    @Option(name: .shortAndLong, help: "Set a drop shadow on the icon.")
    var dropshadow: Bool = false

    @Option(name: .shortAndLong, help: "Set a gradient on the background.")
    var gradient: Bool = false

    @Option(name: [.customLong("overlaydropshadow"), .customShort("D")], help: "Set a drop shadow on the overlay.")
    var overlaydropshadow: Bool = false

    @Option(name: [.customLong("overlaygradient"), .customShort("G")], help: "Set a gradient on the overlay background.")
    var overlaygradient: Bool = false

    // Output option

    @Option(name: .shortAndLong, help: "The output file path (e.g., ~/Desktop/icon.png).")
    var output: String

    mutating func validateSecondaryColour() {
        if secondarycolour == nil || secondarycolour?.isEmpty == true {
            secondarycolour = colour
        }
    }

    mutating func run() throws {
        // Validate secondary colour
        validateSecondaryColour()

        // Validate colors
        guard let foregroundColor = NSColor(hex: colour),
              let backgroundColor = NSColor(hex: bgcolour),
              let secondaryColor = NSColor(hex: secondarycolour ?? colour),
              let overlayFgColor = NSColor(hex: overlaycolour),
              let overlayBgColor = NSColor(hex: overlaybgcolour) else {
            throw ValidationError("Invalid color format. Please use HEX format (e.g., #FFFFFF).")
        }

        // Map CLI style names to GUI style names
        let symbolColourStyle: String
        switch style.lowercased() {
        case "gradient": symbolColourStyle = "Gradient"
        case "palette": symbolColourStyle = "Palette"
        default: symbolColourStyle = "Monotone"
        }

        // Map overlay position string to Alignment
        let overlayAlignmentValue: Alignment
        switch overlayposition.lowercased() {
        case "topleading": overlayAlignmentValue = .topLeading
        case "toptrailing": overlayAlignmentValue = .topTrailing
        case "bottomleading": overlayAlignmentValue = .bottomLeading
        default: overlayAlignmentValue = .bottomTrailing
        }

        // Use the shared IconRenderer
        let renderer = IconRenderer(
            backgroundColor: Color(foregroundNSColor: backgroundColor),
            sfSymbolName: symbol,
            iconSize: 512,
            sfsymbolSize: percentforsymbol,
            symbolColor: Color(foregroundNSColor: foregroundColor),
            paddingSize: 48,
            overlay: overlaysymbol ?? "",
            overlayColor: Color(foregroundNSColor: overlayFgColor),
            overlayBgColor: Color(foregroundNSColor: overlayBgColor),
            dropShadow: dropshadow,
            backgroundGradient: gradient,
            overlayDropShadow: overlaydropshadow,
            overlayBackgroundGradient: overlaygradient,
            symbolColourStyle: symbolColourStyle,
            secondarySymbolColour: Color(foregroundNSColor: secondaryColor),
            overlayPosition: overlayAlignmentValue)
        let pngData = MainActor.assumeIsolated {
            renderer.renderToPNGData()
        }

        guard let data = pngData else {
            throw ValidationError("Failed to render the icon. Check that the symbol name is valid.")
        }

        // Save the icon
        let outputPath = NSString(string: output).expandingTildeInPath
        let url = URL(fileURLWithPath: outputPath)
        try data.write(to: url)

        print("Icon generated and saved to \(outputPath)")
    }
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

// Helper to convert NSColor to SwiftUI Color
extension Color {
    init(foregroundNSColor nsColor: NSColor) {
        self.init(nsColor)
    }
}

// Ensure NSApplication exists for ImageRenderer/SwiftUI support
let _ = NSApplication.shared
SFIconsCLI.main()
