# Runa

A block-based document editor for Linux and Android, built with Flutter.

![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Android-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.1.0-orange)

## Features

- **Markdown blocks** — write with Markdown formatting, live preview, syntax highlighting, and math formula support (LaTeX).
- **Ink/drawing blocks** — freehand ink canvas with a built-in text tool, stylus pressure support, geometric shapes, and a stylus-only mode that ignores touch input.
- **PDF blocks** — embed PDF pages directly into documents with ink annotation support.
- **Image blocks** — insert and annotate images with the same ink tools.
- **Document management** — create, rename, organize and navigate documents and folders from the home screen or editor sidebar.
- **PDF export** — export any document to PDF preserving markdown, math, images and ink strokes. On Android shares via the system share sheet.
- **Recent files** — quick access to the last opened documents.
- **Auto-save** — saves changes automatically at a configurable interval.
- **Themes** — light, dark or system-default.
- **Keyboard shortcuts** — `Ctrl+S` to save, `Tab` to navigate between blocks, and more.

## Downloads

Pre-built binaries are available in the [`dist/`](dist/) folder:

| Platform | File | Notes |
|----------|------|-------|
| Linux — AppImage | `dist/linux/runa-0.1.0-x86_64.AppImage` | Any distro, no install needed |
| Linux — deb | `dist/linux/runa-0.1.0-amd64.deb` | Debian, Ubuntu, Mint… |
| Linux — rpm | `dist/linux/runa-0.1.0-1.x86_64.rpm` | Fedora, openSUSE, RHEL… |
| Linux — tar.gz | `dist/linux/runa-0.1.0-linux-x64.tar.gz` | Manual / any distro |
| Android APK | `dist/android/runa-0.1.0-android.apk` | Direct sideload install |

For detailed installation instructions see **[INSTALL.md](INSTALL.md)**. All binaries are in [`dist/`](dist/).

## Building from source

### Requirements

- [Flutter](https://flutter.dev) 3.x or later
- Dart SDK 3.11 or later
- **Linux:** `zenity` or `kdialog` installed

```bash
# Clone the repository
git clone <repo-url>
cd runa

# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d linux
flutter run -d android

# Build release
flutter build linux --release
flutter build apk --release
```

### Regenerate code

The project uses `build_runner` for Riverpod, Freezed and JSON code generation. Run this after modifying models or notifiers:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Project structure

```
lib/
├── application/   # Business logic: Riverpod notifiers, services, state models
├── data/          # Repository implementations and I/O
├── domain/        # Domain models (Document, Block, Stroke…)
└── presentation/  # Widgets: editor, home screen, sidebar, settings
```

## Tests

```bash
flutter test
```

## Main dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `freezed` | Immutable models |
| `pdf` / `pdfrx` | PDF generation and rendering |
| `flutter_markdown_plus` | Markdown rendering |
| `flutter_math_fork` | Math formulas (LaTeX) |
| `flutter_highlight` | Syntax highlighting |
| `share_plus` | Android/iOS share sheet |
| `path_provider` | Default documents directory |

## License

MIT — see [LICENSE](LICENSE).

---

*This project was largely built with the assistance of an LLM to get a first working prototype off the ground. It's been a fun experiment — in the future I'd like to have more hands-on control over the development and grow it from here.*
