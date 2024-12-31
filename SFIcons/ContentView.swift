import SwiftUI
import UniformTypeIdentifiers
import Cocoa

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, Locale(identifier: "en_CA"))
    }
}

struct ContentView: View {
    // Properties
    @State private var backgroundColor: Color = Color(red: 0.2745, green: 0.6157, blue: 0.8314)
    @State private var symbolColor: Color = .white
    @State private var sfSymbolName: String = "externaldrive.connected.to.line.below"
    @State private var iconSize: CGFloat = 512
    @State private var sfsymbolSize: CGFloat = 50
    

    var body: some View {
        HStack {
            // Icon View
            VStack {
                ZStack {
                    backgroundColor
                        .frame(width: iconSize, height: iconSize)
                        .cornerRadius(iconSize * 0.2) // Rounded corners

                    Image(systemName: sfSymbolName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(symbolColor)
                        .frame(width: iconSize * sfsymbolSize / 100, height: iconSize * sfsymbolSize / 100)
                }

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
            VStack(alignment: .leading, spacing: 20) {
                // Overlay SFSymbol
                VStack(alignment: .leading) {
                    Text("SFSymbol:")
                        .font(.headline)
                    TextField("Enter SFSymbol Name", text: $sfSymbolName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                }

                // SFSymbol Colour Picker
                VStack(alignment: .leading) {
                    Text("SFSymbol Colour:")
                        .font(.headline)
                    ColorPicker("Select Symbol Colour", selection: $symbolColor)
                }
                
                // Base Colour Picker
                VStack(alignment: .leading) {
                    Text("Background Colour:")
                        .font(.headline)
                    ColorPicker("Select Background Colour", selection: $backgroundColor)
                }
                
                // SFSymbol Slider
                VStack(alignment: .leading) {
                    Text("SFSymbol Size: \(String(format: "%.0f", sfsymbolSize))%")
                        .font(.headline)
                    Slider(value: $sfsymbolSize, in: 1...100)
                }
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .padding()
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
    
    var iconView: some View {
        ZStack {
            backgroundColor
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(iconSize * 0.2)

            Image(systemName: sfSymbolName)
                .resizable()
                .scaledToFit()
                .foregroundColor(symbolColor)
                .frame(width: iconSize * 0.5, height: iconSize * 0.5)
        }
    }
}

//struct SFIconsCommands: Commands {
//    var body: some Commands {
//        CommandGroup(replacing: .newItem) {
//            Button("Install CLI Tool") {
//                // Create an instance of InstallCLITool and call its method
//                let installTool = InstallCLITool(title: "Install CLI Tool", action: nil, keyEquivalent: "")
//                installTool.installCLI()
//            }
//            .keyboardShortcut("i", modifiers: .command)
//        }
//    }
//}

@main

struct IconGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .commands {
//            SFIconsCommands() // Add the custom commands
//        }
    }
}
