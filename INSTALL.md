# Installation Guide

## Linux

### AppImage (recommended — any distro, no installation needed)

Download `runa-0.1.0-x86_64.AppImage`, then:

```bash
chmod +x runa-0.1.0-x86_64.AppImage
./runa-0.1.0-x86_64.AppImage
```

That's it. No installation required — the AppImage is self-contained.

> **Optional:** integrate it with your desktop (launcher, file manager, etc.) using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher).

---

### .deb (Debian, Ubuntu, Linux Mint, Pop!_OS…)

```bash
sudo dpkg -i runa-0.1.0-amd64.deb
```

Launch from your application menu or run:

```bash
runa
```

To uninstall:

```bash
sudo dpkg -r runa
```

---

### .rpm (Fedora, openSUSE, RHEL, AlmaLinux…)

**Fedora / RHEL:**
```bash
sudo rpm -i runa-0.1.0-1.x86_64.rpm
```

Or with `dnf` to handle dependencies automatically:
```bash
sudo dnf install ./runa-0.1.0-1.x86_64.rpm
```

**openSUSE:**
```bash
sudo zypper install ./runa-0.1.0-1.x86_64.rpm
```

Launch from your application menu or run:

```bash
runa
```

To uninstall:

```bash
sudo rpm -e runa          # rpm
sudo dnf remove runa      # dnf
```

---

### .tar.gz (manual install — any distro)

```bash
# Extract
tar -xzf runa-0.1.0-linux-x64.tar.gz

# Run directly (no install needed)
./bundle/runa
```

**Optional: install system-wide**

```bash
# Copy files
sudo cp bundle/runa /usr/local/bin/runa
sudo cp -r bundle/lib /usr/local/lib/runa-lib
sudo cp -r bundle/data /usr/local/share/runa

# Make the binary find its libraries
sudo tee /usr/local/bin/runa > /dev/null << 'EOF'
#!/bin/sh
export LD_LIBRARY_PATH="/usr/local/lib/runa-lib:$LD_LIBRARY_PATH"
exec /usr/local/lib/runa-lib/runa-bin "$@"
EOF
sudo chmod +x /usr/local/bin/runa
```

To uninstall:

```bash
sudo rm /usr/local/bin/runa
sudo rm -rf /usr/local/lib/runa-lib
sudo rm -rf /usr/local/share/runa
```

---

### Linux dependency: file picker

Runa uses `zenity` or `kdialog` for native file dialogs. Install one if you don't have it:

| Distro | Command |
|--------|---------|
| Debian / Ubuntu | `sudo apt install zenity` |
| Fedora | `sudo dnf install zenity` |
| Arch / CachyOS | `sudo pacman -S zenity` |
| openSUSE | `sudo zypper install zenity` |
| KDE users | `kdialog` is usually pre-installed |

---

## Android

### Install the APK directly (sideload)

1. Download `runa-0.1.0-android.apk` to your device.
2. Open the file from your file manager.
3. If prompted, enable **"Install from unknown sources"** for your browser or file manager:
   - Go to **Settings → Apps → Special app access → Install unknown apps**
   - Enable it for the app you used to open the file.
4. Tap **Install**.

> The APK is signed with a release key, so updates must come from the same source (or the Play Store if published there).

### Via ADB (developers)

```bash
adb install runa-0.1.0-android.apk
```

### Play Store (AAB)

The `.aab` file (`runa-0.1.0-android.aab`) is for submitting to the Google Play Store. It cannot be installed directly on a device.
