# Clipboard Manager

**Minimal, beautiful clipboard history for your Mac.**

A native macOS menubar app that remembers everything you copy.  
No dock icon, no distractions — just a clipboard icon in your menu bar.

## Features

- **Automatic capture** — every `Cmd+C` is saved instantly
- **Search** — filter through hundreds of items in milliseconds
- **Pin** — keep important snippets forever
- **Auto-clean** — unpinned items vanish after 1 hour
- **Native feel** — vibrancy, animations, dark/light mode
- **Privacy-first** — everything stays on your machine

## Usage

Click the clipboard icon in the menu bar → see your history → click any item to copy it back.

| Key | Action |
|---|---|
| Click item | Copy to clipboard |
| Pin icon | Keep item forever |
| X icon | Remove item |
| Search field | Filter history |

## Install

```bash
git clone https://github.com/sjgagahvabw/clipboard-manager.git
cd clipboard-manager
make run
```

Or open the `.xcodeproj` in Xcode and hit Run.

## Build

```bash
make        # compile + bundle
make run    # launch
make clean  # remove build artifacts
```

No dependencies. No package managers. Just Swift.

## Icon

The app lives in your menu bar (top-right corner).  
It does **not** appear in the Dock.

## License

MIT
