# SFIcons

![Screenshot of UI](https://www.neverhadtofight.com/wp-content/uploads/2024/12/Screenshot-2025-01-06-at-4.17.55%E2%80%AFPM.png)

Generate icons in the style of macOS using Apple's SF Symbols. Perfect for your self-service system's catalogue (or at least perfect for mine). Available as both a native macOS GUI app and a command-line tool.

There are over 6,000 SF Symbols to choose from. To browse available symbol names, download the [SF Symbols](https://devimages-cdn.apple.com/design/resources/download/SF-Symbols-6.dmg) app from Apple.

## Features

### GUI App

- **Icon Preview** with live updates as you adjust settings
- **Inspector Panel** (toggle via toolbar) with collapsible sections:
  - **Symbol** -- choose an SF Symbol, set its colour style (Monotone, Gradient, or Palette), pick primary and secondary colours, adjust background colour, and control symbol size with a slider
  - **Overlay** -- add a secondary SF Symbol badge in any corner (Top Leading, Top Trailing, Bottom Leading, Bottom Trailing) with independent colour, background colour, drop shadow, and gradient controls
  - **Advanced** -- toggle drop shadow and background gradient on the main icon
  - **Colour Palette** -- 10 pre-defined colour palettes (Purple, Blue, Pastel, Kids, Spring, Retro, Earth, Green, and Space) that apply a coordinated set of colours and disable gradients for a clean look
- **Export** menu with two options:
  - **Export as PNG** -- save the rendered icon as a PNG image
  - **Export Settings** -- save all current settings as a JSON file
- **Import Settings** -- load a previously exported JSON settings file to restore a configuration
- **Share** -- share the icon via the macOS share sheet
- **Reset to Defaults** -- restore all settings to their original values
- **Localised** in English (en-CA, en, en-AU, en-GB) and French (fr, fr-CA)
- Settings are persisted between sessions via UserDefaults

### CLI Tool (`sficons`)

The CLI uses the same rendering engine as the GUI, so output is identical.

#### Installing the symlink

Until version 2, the app was distributed with a PKG that included a script to create the symlink. I've decided to do away with that. If you want to use the CLI, please either call the full path `/Applications/SFIcons.app/Contents/SharedSupport/sficons` or add a symlink on your own.

```
#!/bin/zsh --no-rcs

symlink="/usr/local/bin/sficons"
appPath="/Applications/SFIcons.app/Contents/SharedSupport/sficons"

if [ -L "$symlink" ]; then
    echo "Symlink already exists. Nothing to do."
    exit 0
fi

ln -s "$appPath" "$symlink"

if [ $? -eq 0 ]; then
    echo "Symlink created successfully."
else
    echo "Failed to create symlink."
    exit 1
fi

exit 0
```

#### Usage of CLI

```
USAGE: sficons --symbol <symbol> --colour <colour> --bgcolour <bgcolour> --percentforsymbol <percentforsymbol> --output <output> [options]
```

#### Required Options

| Flag | Description |
|------|-------------|
| `-s, --symbol` | SF Symbol name (e.g. `externaldrive.connected.to.line.below`) |
| `-c, --colour, --color` | Foreground colour in HEX (e.g. `#FFFFFF`) |
| `-b, --bgcolour, --bgcolor` | Background colour in HEX (e.g. `#469DD4`) |
| `-p, --percentforsymbol` | Symbol size as a percentage (e.g. `75`) |
| `-o, --output` | Output file path (e.g. `~/Desktop/icon.png`) |

#### Optional Flags

| Flag | Description |
|------|-------------|
| `-S, --secondarycolour, --secondarycolor` | Secondary foreground colour for Gradient/Palette styles |
| `-y, --style` | Symbol colour style: `monotone` (default), `gradient`, or `palette` |
| `-O, --overlaysymbol` | Overlay SF Symbol name (e.g. `cat`) |
| `-C, --overlaycolour, --overlaycolor` | Overlay symbol colour (default: `#FFFFFF`) |
| `-B, --overlaybgcolour, --overlaybgcolor` | Overlay background colour (default: `#469DD4`) |
| `-P, --overlayposition` | Overlay corner: `bottomtrailing` (default), `bottomleading`, `toptrailing`, `topleading` |
| `-d, --dropshadow` | Enable drop shadow on the icon |
| `-g, --gradient` | Enable background gradient |
| `-D, --overlaydropshadow` | Enable drop shadow on the overlay |
| `-G, --overlaygradient` | Enable gradient on the overlay background |

#### Example

```bash
sficons \
  --symbol "externaldrive.connected.to.line.below" \
  --colour "#FFFFFF" \
  --bgcolour "#054460" \
  --percentforsymbol 75 \
  --dropshadow true \
  --gradient true \
  --output ~/Desktop/icon.png
```

## Requirements

macOS 15.0 or later

## Licence

[Apache License 2.0](LICENSE)

## Credits

Built by Adam Anklewicz. Contributions welcome!
