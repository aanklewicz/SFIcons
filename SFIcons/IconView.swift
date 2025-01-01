import SwiftUI

struct IconView: View {
    var backgroundColor: Color
    var sfSymbolName: String
    var iconSize: CGFloat
    var sfsymbolSize: CGFloat
    var symbolColor: Color
    var paddingSize: CGFloat

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
    }
}
