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

    @State private var sfSymbolName: String = UserDefaults.standard.string(forKey: "sfSymbolName") ?? "externaldrive.connected.to.line.below"
    @State private var iconSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "iconSize") == 0 ? 512 : UserDefaults.standard.float(forKey: "iconSize"))
    
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


    var body: some View {
        HStack {
            // Icon View
            VStack {
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
                         overlayBackgroundGradient: overlayBackgroundGradient)


                HStack {
                    // Share Button
                    Button(action: shareIcon) {
                        Label(NSLocalizedString("Share", comment: "Share button label"), systemImage: "square.and.arrow.up")
                    }
                    .keyboardShortcut("s")

                    // Export Button
                    Button(action: saveIconToFileSystem) {
                        Label("Export", systemImage: "folder")
                    }
                    .keyboardShortcut("e")
                    .padding()
                }
            }
            .padding()

            // Options Panel
            VStack(alignment: .leading) {
                // SFSymbol
                TextField("Enter SFSymbol Name", text: $sfSymbolName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)

                // SFSymbol Colour Picker
               ColorPicker("Select Symbol Colour", selection: $symbolColor)
                    .font(.headline)
                
                // Base Colour Picker
                ColorPicker("Select Background Colour", selection: $backgroundColor)
                    .font(.headline)
                
                // SFSymbol Slider
                Text("SFSymbol Size: \(String(format: "%.0f", sfsymbolSize))%")
                    .font(.headline)
                Slider(value: $sfsymbolSize, in: 1...100)
                
                // Overlay Disclosure Group
                DisclosureGroup("Add an overlay") {
                    VStack(alignment: .leading) {
                        TextField("Overlay", text: $overlay)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                        
                        ColorPicker("Overlay Colour", selection: $overlayColor)
                            .font(.headline)
                        
                        ColorPicker("Overlay Background Colour", selection: $overlayBgColor)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading], 15)
                }
                .font(.headline)
                
                // Advanced Disclosure Group
                DisclosureGroup("Advanced") {
                    VStack(alignment: .leading) {
                        Toggle("Drop Shadow", isOn: $dropShadow)
                            .font(.headline)
                        
                        Toggle("Background Gradient", isOn: $backgroundGradient)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading], 15)
                }
                .font(.headline)
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .padding()
        .onDisappear {
            saveState()
        }
    }

    // Share Icon Function
    func shareIcon() {
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 2.0 // Retina-quality rendering

        // Render the icon to PNG
        if let imageData = renderer.nsImage?.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: imageData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            // Temporary file for sharing
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempURL = tempDirectory.appendingPathComponent("icon.png")

            do {
                try pngData.write(to: tempURL)

                // Open the share sheet
                let picker = NSSharingServicePicker(items: [tempURL])
                if let window = NSApplication.shared.windows.first {
                    picker.show(relativeTo: .zero, of: window.contentView!, preferredEdge: .minY)
                }
            } catch {
                print("Failed to save PNG: \(error)")
            }
        } else {
            print("Failed to render the icon.")
        }
    }

    func saveIconToFileSystem() {
        // Render the icon to PNG
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 2.0 // Retina-quality rendering

        // Ensure nsImage is properly rendered
        guard let imageData = renderer.nsImage?.tiffRepresentation else {
            print("Failed to render the icon.")
            return
        }

        // Convert to PNG
        guard let bitmapImage = NSBitmapImageRep(data: imageData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("Failed to convert the image to PNG.")
            return
        }

        // Perform file-saving operation on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            // Show the save panel on the main thread
            DispatchQueue.main.async {
                let savePanel = NSSavePanel()
                savePanel.allowedContentTypes = [UTType.png]  // Restrict to PNG
                savePanel.nameFieldStringValue = "icon.png"

                savePanel.begin { result in
                    if result == .OK, let url = savePanel.url {
                        // Perform the file write on a background thread
                        DispatchQueue.global(qos: .background).async {
                            do {
                                print("Saving file to: \(url.path)")
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
                    } else {
                        print("Save panel was canceled or failed.")
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
        UserDefaults.standard.set(sfSymbolName, forKey: "sfSymbolName")
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
                 overlayBackgroundGradient: overlayBackgroundGradient)
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
