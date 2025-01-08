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

    var body: some View {
        ZStack {
            backgroundColor
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize * 0.2) // Rounded corners
                .padding(paddingSize)
                .background(Color.clear)
                

            Image(systemName: sfSymbolName)
                .resizable()
                .scaledToFit()
                .foregroundColor(symbolColor)
                .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
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
