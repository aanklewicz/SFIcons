import SwiftUI

struct IconView: View {
    var backgroundColor: Color
    var sfSymbolName: String
    var iconSize: CGFloat
    var sfsymbolSize: CGFloat
    var symbolColor: Color
    var paddingSize: CGFloat
    var overlay: String
    var overlayColor: Color
    var overlayBgColor: Color
    var dropShadow: Bool = true
    var backgroundGradient: Bool = true
    var overlayDropShadow: Bool = true
    var overlayBackgroundGradient: Bool = true
    var symbolColourStyle: String
    var secondarySymbolColour: Color

    var body: some View {
        let saturatedColor: Color = {
                    let nsColor = NSColor(backgroundColor)
                    var hue: CGFloat = 0
                    var sat: CGFloat = 0
                    var bri: CGFloat = 0
                    var alpha: CGFloat = 0
                    nsColor.usingColorSpace(.deviceRGB)?.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                    return Color(hue: hue, saturation: 0.8, brightness: bri, opacity: alpha)
                }()
        
        let saturatedOverlayColor: Color = {
                    let nsColor = NSColor(overlayBgColor)
                    var hue: CGFloat = 0
                    var sat: CGFloat = 0
                    var bri: CGFloat = 0
                    var alpha: CGFloat = 0
                    nsColor.usingColorSpace(.deviceRGB)?.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                    return Color(hue: hue, saturation: 0.8, brightness: bri, opacity: alpha)
                }()
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: backgroundGradient ? [backgroundColor, saturatedColor] : [backgroundColor, backgroundColor]), startPoint: .bottom, endPoint: .top)
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize * 0.2) // Rounded corners
                .padding(paddingSize)
                .background(Color.clear)
                .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)

            if symbolColourStyle == "Monotone" {
                Image(systemName: sfSymbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(symbolColor)
                    .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                    .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)
            }
            else if symbolColourStyle == "Gradient" {
                Image(systemName: "sfSymbolName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [symbolColor, secondarySymbolColour]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            Image(systemName: sfSymbolName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                        )
                    )
                    .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)
            }
            else if symbolColourStyle == "Palette" {
                Image(systemName: sfSymbolName)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(symbolColor, secondarySymbolColour)
                    .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                    .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)
            }
            
            
        }
        .overlay(
            Group {
                if !overlay.isEmpty {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: overlayBackgroundGradient ? [overlayBgColor, saturatedOverlayColor] : [overlayBgColor, overlayBgColor]), startPoint: .bottom, endPoint: .top)
                            .frame(width: iconSize / 4, height: iconSize / 4)
                            .cornerRadius(iconSize / 8 * 0.2)
                            .shadow(radius: overlayDropShadow ? 5 : 0, x: 0, y: overlayDropShadow ? 5 : 0)
                        
                        Image(systemName: overlay)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(overlayColor)
                            .frame(width: iconSize * sfsymbolSize / 400, height: iconSize * sfsymbolSize / 400)
                            .padding(5)
                    }
                    .padding(78)
                }
            },
            alignment: .bottomTrailing
        )
    }
}
