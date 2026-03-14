#!/usr/bin/env bash
set -e

echo "Installing cosmic-applet-homey"

if [ ! -f "target/release/cosmic-applet-homey" ]; then
    echo "Binary not found. Building..."
    cargo build --release
fi

install -Dm755 target/release/cosmic-applet-homey ~/.local/bin/cosmic-applet-homey
install -Dm644 data/com.github.cosmic-applet-homey.desktop \
    ~/.local/share/applications/com.github.cosmic-applet-homey.desktop
install -Dm644 icon.png \
    ~/.local/share/icons/hicolor/512x512/apps/com.github.cosmic-applet-homey.png

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor >/dev/null 2>&1 || true
fi

echo ""
echo "Installation complete!"
echo ""
echo "To use the applet:"
echo "1. Log out and back in, or restart the COSMIC panel"
echo "2. Go to Settings -> Panel -> Applets"
echo "3. Add 'Homey' to the panel"
