import SwiftUI
import AppKit

@MainActor
struct IconRenderer {
    var backgroundColor: Color
    var sfSymbolName: String
    var iconSize: CGFloat
    var sfsymbolSize: CGFloat
    var symbolColor: Color
    var paddingSize: CGFloat
    var overlay: String
    var overlayColor: Color
    var overlayBgColor: Color
    var dropShadow: Bool
    var backgroundGradient: Bool
    var overlayDropShadow: Bool
    var overlayBackgroundGradient: Bool
    var symbolColourStyle: String
    var secondarySymbolColour: Color
    var overlayPosition: Alignment = .bottomTrailing

    var iconView: some View {
        IconView(backgroundColor: backgroundColor,
                 sfSymbolName: sfSymbolName,
                 iconSize: iconSize,
                 sfsymbolSize: sfsymbolSize,
                 symbolColor: symbolColor,
                 paddingSize: paddingSize,
                 overlay: overlay,
                 overlayColor: overlayColor,
                 overlayBgColor: overlayBgColor,
                 dropShadow: dropShadow,
                 backgroundGradient: backgroundGradient,
                 overlayDropShadow: overlayDropShadow,
                 overlayBackgroundGradient: overlayBackgroundGradient,
                 symbolColourStyle: symbolColourStyle,
                 secondarySymbolColour: secondarySymbolColour,
                 overlayPosition: overlayPosition)
    }

    func renderToPNGData() -> Data? {
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 2.0
        guard let image = renderer.nsImage,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return pngData
    }
}
