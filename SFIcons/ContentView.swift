import SwiftUI
import UniformTypeIdentifiers
import Cocoa

// To preview in other languages, edit the identifier
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, Locale(identifier: "en_CA"))
    }
}

struct IconSettings: Codable {
    var sfSymbolName: String
    var symbolColourStyle: String
    var symbolColor: String
    var secondarySymbolColour: String
    var backgroundColor: String
    var sfsymbolSize: Double
    var overlay: String
    var overlayPosition: String
    var overlayColor: String
    var overlayBgColor: String
    var overlayDropShadow: Bool
    var overlayBackgroundGradient: Bool
    var dropShadow: Bool
    var backgroundGradient: Bool
}

extension Color {
    func toHex() -> String {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor(self)
        let r = Int(round(nsColor.redComponent * 255))
        let g = Int(round(nsColor.greenComponent * 255))
        let b = Int(round(nsColor.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        guard hexString.count == 6,
              let rgb = Int(hexString, radix: 16) else { return nil }
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

struct ColourPalette: Identifiable {
    let id: String
    let name: String
    let colours: [Color]

    static let palettes: [ColourPalette] = [
        ColourPalette(id: "purple", name: "Purple", colours: [
            Color(hex: "#6B3F69")!, Color(hex: "#8D5F8C")!, Color(hex: "#A376A2")!, Color(hex: "#DDC3C3")!
        ]),
        ColourPalette(id: "blue", name: "Blue", colours: [
            Color(hex: "#213448")!, Color(hex: "#547792")!, Color(hex: "#94B4C1")!, Color(hex: "#EAE0CF")!
        ]),
        ColourPalette(id: "pastel", name: "Pastel", colours: [
            Color(hex: "#5A9CB5")!, Color(hex: "#FACE68")!, Color(hex: "#FAAC68")!, Color(hex: "#FA6868")!
        ]),
        ColourPalette(id: "kids", name: "Kids", colours: [
            Color(hex: "#F6B1CE")!, Color(hex: "#1581BF")!, Color(hex: "#3DB6B1")!, Color(hex: "#CCE5CF")!
        ]),
        ColourPalette(id: "spring", name: "Spring", colours: [
            Color(hex: "#F5D2D2")!, Color(hex: "#F8F7BA")!, Color(hex: "#BDE3C3")!, Color(hex: "#A3CCDA")!
        ]),
        ColourPalette(id: "retro", name: "Retro", colours: [
            Color(hex: "#808836")!, Color(hex: "#FFBF00")!, Color(hex: "#FF9A00")!, Color(hex: "#D10363")!
        ]),
        ColourPalette(id: "earth", name: "Earth", colours: [
            Color(hex: "#798645")!, Color(hex: "#FEFAE0")!, Color(hex: "#F2EED7")!, Color(hex: "#626F47")!
        ]),
        ColourPalette(id: "green", name: "Green", colours: [
            Color(hex: "#4B5945")!, Color(hex: "#66785F")!, Color(hex: "#91AC8F")!, Color(hex: "#B2C9AD")!
        ]),
    ]
}

struct ContentView: View {
    // Setting up the variables
    
    // Variables for primary items
    @State private var backgroundColor: Color = {
        if let data = UserDefaults.standard.data(forKey: "backgroundColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(color)
        }
        return Color(red: 0.0196, green: 0.2667, blue: 0.3686)
    }()
    
    @State private var symbolColor: Color = {
        if let data = UserDefaults.standard.data(forKey: "symbolColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(color)
        }
        return .white
    }()
    
    @State private var secondarySymbolColour: Color = {
        if let data = UserDefaults.standard.data(forKey: "secondarySymbolColour"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(color)
        }
        return .white
    }()

    @State private var sfSymbolName: String = UserDefaults.standard.string(forKey: "sfSymbolName") ?? "externaldrive.connected.to.line.below"
    @State private var iconSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "iconSize") == 0 ? 512 : UserDefaults.standard.float(forKey: "iconSize"))
    
    @State private var symbolColourStyle: String = UserDefaults.standard.string(forKey: "symbolColourStyle") ?? "Monotone"
    
    // Variables for Advanced Settings
    @State private var dropShadow: Bool = UserDefaults.standard.object(forKey: "dropShadow") as? Bool ?? true
    @State private var backgroundGradient: Bool = UserDefaults.standard.object(forKey: "backgroundGradient") as? Bool ?? true
    
    // Variables for Overlay
    @State private var overlay: String = UserDefaults.standard.string(forKey: "overlay") ?? ""
    @State private var sfsymbolSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "sfsymbolSize") == 0 ? 75 : UserDefaults.standard.float(forKey: "sfsymbolSize"))
    @State private var overlayColor: Color = {
        if let data = UserDefaults.standard.data(forKey: "overlayColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(color)
        }
        return Color(red: 0.8314, green: 0.9451, blue: 0.9569)
    }()
    @State private var overlayBgColor: Color = {
        if let data = UserDefaults.standard.data(forKey: "overlayBgColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(color)
        }
        return Color(red: 0.0941, green: 0.6039, blue: 0.7059)
    }()
    @State private var overlayDropShadow: Bool = UserDefaults.standard.object(forKey: "dropShadow") as? Bool ?? true
    @State private var overlayBackgroundGradient: Bool = UserDefaults.standard.object(forKey: "backgroundGradient") as? Bool ?? true
    @State private var overlayPosition: String = UserDefaults.standard.string(forKey: "overlayPosition") ?? "Bottom Trailing"
    
    // Padding Size variable
    private var paddingSize: CGFloat {
        return 48 * 512 / iconSize
    }

    @State private var showInspector: Bool = true
    @State private var showOverlay: Bool = false
    @State private var showAdvanced: Bool = false
    @State private var showPalettes: Bool = false

    var body: some View {
        // Main content: icon preview and action buttons
        VStack {
            Spacer()
            iconRenderer.iconView
            Spacer()
            HStack {
                Button(action: shareIcon) {
                    Label(NSLocalizedString("Share", comment: "Share button label"), systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut("s")

                Menu {
                    Button(action: exportIconAsPNG) {
                        Label("Export as PNG", systemImage: "photo")
                    }
                    Button(action: exportSettingsAsJSON) {
                        Label("Export Settings", systemImage: "doc.text")
                    }
                } label: {
                    Label("Export", systemImage: "folder")
                }

                Button(action: importSettingsFromJSON) {
                    Label("Import Settings", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut("i")

                Button(action: resetToDefaults) {
                    Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                }
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.trailing")
                }
                .help("Toggle Inspector")
            }
        }
        .inspector(isPresented: $showInspector) {
            Form {
                Section("Symbol") {
                    TextField("Enter SFSymbol Name", text: $sfSymbolName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Select Symbol Colour Style", selection: $symbolColourStyle) {
                        Text("Monotone").tag("Monotone")
                        Text("Gradient").tag("Gradient")
                        Text("Palette").tag("Palette")
                    }

                    ColorPicker("Select Symbol Colour", selection: $symbolColor)

                    if symbolColourStyle != "Monotone" {
                        ColorPicker("Secondary Symbol Colour", selection: $secondarySymbolColour)
                    }

                    ColorPicker("Select Background Colour", selection: $backgroundColor)

                    Text("SFSymbol Size: \(String(format: "%.0f", sfsymbolSize))%")
                    Slider(value: $sfsymbolSize, in: 1...100)
                }

                DisclosureGroup("Overlay", isExpanded: $showOverlay) {
                    TextField("Overlay", text: $overlay)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Overlay Position", selection: $overlayPosition) {
                        Text("Top Leading").tag("Top Leading")
                        Text("Top Trailing").tag("Top Trailing")
                        Text("Bottom Leading").tag("Bottom Leading")
                        Text("Bottom Trailing").tag("Bottom Trailing")
                    }

                    ColorPicker("Overlay Colour", selection: $overlayColor)

                    ColorPicker("Overlay Background Colour", selection: $overlayBgColor)

                    Toggle("Overlay Drop Shadow", isOn: $overlayDropShadow)

                    Toggle("Overlay Background Gradient", isOn: $overlayBackgroundGradient)
                }

                DisclosureGroup("Advanced", isExpanded: $showAdvanced) {
                    Toggle("Drop Shadow", isOn: $dropShadow)

                    Toggle("Background Gradient", isOn: $backgroundGradient)
                }

                DisclosureGroup("Colour Palette", isExpanded: $showPalettes) {
                    ForEach(ColourPalette.palettes) { palette in
                        Button(action: { applyPalette(palette) }) {
                            HStack {
                                Text(palette.name)
                                Spacer()
                                ForEach(0..<palette.colours.count, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(palette.colours[i])
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
        }
        .frame(minWidth: 600, minHeight: 500)
        .onDisappear {
            saveState()
        }
    }

    private var overlayAlignmentValue: Alignment {
        switch overlayPosition {
        case "Top Leading": return .topLeading
        case "Top Trailing": return .topTrailing
        case "Bottom Leading": return .bottomLeading
        default: return .bottomTrailing
        }
    }

    private var iconRenderer: IconRenderer {
        IconRenderer(backgroundColor: backgroundColor,
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
                     overlayPosition: overlayAlignmentValue)
    }

    // Share Icon Function
    func shareIcon() {
        guard let pngData = iconRenderer.renderToPNGData() else {
            print("Failed to render the icon.")
            return
        }

        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent("icon.png")

        do {
            try pngData.write(to: tempURL)

            let picker = NSSharingServicePicker(items: [tempURL])
            if let window = NSApplication.shared.windows.first {
                picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
            }
        } catch {
            print("Failed to save PNG: \(error)")
        }
    }

    func exportIconAsPNG() {
        guard let pngData = iconRenderer.renderToPNGData() else {
            print("Failed to render the icon.")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.png]
        savePanel.nameFieldStringValue = "icon.png"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                DispatchQueue.global(qos: .background).async {
                    do {
                        try pngData.write(to: url)
                        DispatchQueue.main.async {
                            print("File saved successfully to: \(url.path)")
                        }
                    } catch {
                        DispatchQueue.main.async {
                            print("Failed to save file: \(error)")
                        }
                    }
                }
            }
        }
    }

    func exportSettingsAsJSON() {
        let settings = IconSettings(
            sfSymbolName: sfSymbolName,
            symbolColourStyle: symbolColourStyle,
            symbolColor: symbolColor.toHex(),
            secondarySymbolColour: secondarySymbolColour.toHex(),
            backgroundColor: backgroundColor.toHex(),
            sfsymbolSize: sfsymbolSize,
            overlay: overlay,
            overlayPosition: overlayPosition,
            overlayColor: overlayColor.toHex(),
            overlayBgColor: overlayBgColor.toHex(),
            overlayDropShadow: overlayDropShadow,
            overlayBackgroundGradient: overlayBackgroundGradient,
            dropShadow: dropShadow,
            backgroundGradient: backgroundGradient
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(settings) else {
            print("Failed to encode settings.")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.json]
        savePanel.nameFieldStringValue = "icon-settings.json"

        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try jsonData.write(to: url)
                    print("Settings saved to: \(url.path)")
                } catch {
                    print("Failed to save settings: \(error)")
                }
            }
        }
    }

    func importSettingsFromJSON() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.json]
        openPanel.allowsMultipleSelection = false

        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let settings = try JSONDecoder().decode(IconSettings.self, from: data)
                    applySettings(settings)
                } catch {
                    print("Failed to import settings: \(error)")
                }
            }
        }
    }

    private func applySettings(_ settings: IconSettings) {
        sfSymbolName = settings.sfSymbolName
        symbolColourStyle = settings.symbolColourStyle
        sfsymbolSize = settings.sfsymbolSize
        overlay = settings.overlay
        overlayPosition = settings.overlayPosition
        overlayDropShadow = settings.overlayDropShadow
        overlayBackgroundGradient = settings.overlayBackgroundGradient
        dropShadow = settings.dropShadow
        backgroundGradient = settings.backgroundGradient

        if let color = Color(hex: settings.symbolColor) { symbolColor = color }
        if let color = Color(hex: settings.secondarySymbolColour) { secondarySymbolColour = color }
        if let color = Color(hex: settings.backgroundColor) { backgroundColor = color }
        if let color = Color(hex: settings.overlayColor) { overlayColor = color }
        if let color = Color(hex: settings.overlayBgColor) { overlayBgColor = color }
    }

    private func applyPalette(_ palette: ColourPalette) {
        backgroundColor = palette.colours[0]
        symbolColor = palette.colours[1]
        secondarySymbolColour = palette.colours[2]
        overlayColor = palette.colours[1]
        overlayBgColor = palette.colours[3]
        backgroundGradient = false
        overlayBackgroundGradient = false
    }

    private func resetToDefaults() {
        backgroundColor = Color(red: 0.0196, green: 0.2667, blue: 0.3686)
        symbolColor = .white
        secondarySymbolColour = .white
        sfSymbolName = "externaldrive.connected.to.line.below"
        iconSize = 512
        symbolColourStyle = "Monotone"
        sfsymbolSize = 75
        dropShadow = true
        backgroundGradient = true
        overlay = ""
        overlayPosition = "Bottom Trailing"
        overlayColor = Color(red: 0.8314, green: 0.9451, blue: 0.9569)
        overlayBgColor = Color(red: 0.0941, green: 0.6039, blue: 0.7059)
        overlayDropShadow = true
        overlayBackgroundGradient = true
    }

    private func saveState() {
        if let backgroundColorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(backgroundColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(backgroundColorData, forKey: "backgroundColor")
        }
        if let symbolColorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(symbolColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(symbolColorData, forKey: "symbolColor")
        }
        if let secondarySymbolColourData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(secondarySymbolColour), requiringSecureCoding: false) {
            UserDefaults.standard.set(secondarySymbolColourData, forKey: "secondarySymbolColour")
        }
        UserDefaults.standard.set(sfSymbolName, forKey: "sfSymbolName")
        UserDefaults.standard.set(symbolColourStyle, forKey: "symbolColourStyle")
        UserDefaults.standard.set(Float(iconSize), forKey: "iconSize")
        UserDefaults.standard.set(Float(sfsymbolSize), forKey: "sfsymbolSize")
        UserDefaults.standard.set(dropShadow, forKey: "dropShadow")
        UserDefaults.standard.set(backgroundGradient, forKey: "backgroundGradient")
        UserDefaults.standard.set(overlayDropShadow, forKey: "overlayDropShadow")
        UserDefaults.standard.set(overlayBackgroundGradient, forKey: "overlayBackgroundGradient")
        UserDefaults.standard.set(overlay, forKey: "overlay")
        UserDefaults.standard.set(overlayPosition, forKey: "overlayPosition")
        if let overlayColorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(overlayColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(overlayColorData, forKey: "overlayColor")
        }
        if let overlayBgColorData = try? NSKeyedArchiver.archivedData(withRootObject: NSColor(overlayBgColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(overlayBgColorData, forKey: "overlayBgColor")
        }
    }
    
}

@main

struct IconGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
