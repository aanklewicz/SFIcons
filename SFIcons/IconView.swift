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

    var body: some View {
        let saturatedColor: Color = {
                    let nsColor = NSColor(backgroundColor)
                    var hue: CGFloat = 0
                    var sat: CGFloat = 0
                    var bri: CGFloat = 0
                    var alpha: CGFloat = 0
                    nsColor.usingColorSpace(.deviceRGB)?.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                    return Color(hue: hue, saturation: 0.8, brightness: bri, opacity: alpha) // Apple appears to being using 80% saturation for their icon gradients
                }()
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: backgroundGradient ? [backgroundColor, saturatedColor] : [backgroundColor, backgroundColor]), startPoint: .bottom, endPoint: .top)
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize * 0.2) // Rounded corners
                .padding(paddingSize)
                .background(Color.clear)
                .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)

                

            Image(systemName: sfSymbolName)
                .resizable()
                .scaledToFit()
                .foregroundColor(symbolColor)
                .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                .shadow(radius: dropShadow ? 5 : 0, x: 0, y: dropShadow ? 5 : 0)
        }
        .overlay(
            Group {
                if !overlay.isEmpty {
                    ZStack {
                        overlayBgColor
                            .frame(width: iconSize / 4, height: iconSize / 4)
                            .cornerRadius(iconSize / 8 * 0.2)
                            .shadow(radius: 4, x: 2, y: 2)
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
