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
    
    // Padding Size variable
    private var paddingSize: CGFloat {
        return 48 * 512 / iconSize
    }

    @State private var showInspector: Bool = true

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

                Button(action: saveIconToFileSystem) {
                    Label("Export", systemImage: "folder")
                }
                .keyboardShortcut("e")
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

                Section("Overlay") {
                    TextField("Overlay", text: $overlay)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    ColorPicker("Overlay Colour", selection: $overlayColor)

                    ColorPicker("Overlay Background Colour", selection: $overlayBgColor)

                    Toggle("Overlay Drop Shadow", isOn: $overlayDropShadow)

                    Toggle("Overlay Background Gradient", isOn: $overlayBackgroundGradient)
                }

                Section("Advanced") {
                    Toggle("Drop Shadow", isOn: $dropShadow)

                    Toggle("Background Gradient", isOn: $backgroundGradient)
                }
            }
            .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
        }
        .frame(minWidth: 600, minHeight: 500)
        .onDisappear {
            saveState()
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
                     secondarySymbolColour: secondarySymbolColour)
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

    func saveIconToFileSystem() {
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
