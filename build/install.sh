#!/bin/bash

# ZmRef Post-Install Script for Arch Linux
# This script installs ZmRef to the system

APP_NAME="ZmRef"
APP_EXEC="zmref"
ICON_SRC="/opt/zmref/resources/app/build/zmref.png"
ICON_DEST="/usr/share/icons/hicolor/512x512/apps/zmref.png"
DESKTOP_SRC="/opt/zmref/resources/app/build/zmref.desktop"
DESKTOP_DEST="/usr/share/applications/zmref.desktop"

echo "Installing $APP_NAME..."

# Copy icon
if [ -f "$ICON_SRC" ]; then
    sudo cp "$ICON_SRC" "$ICON_DEST"
    echo "✓ Icon installed"
else
    echo "✗ Icon not found at $ICON_SRC"
fi

# Copy desktop file
if [ -f "$DESKTOP_SRC" ]; then
    sudo cp "$DESKTOP_SRC" "$DESKTOP_DEST"
    sudo chmod +x "$DESKTOP_DEST"
    echo "✓ Desktop file installed"
else
    echo "✗ Desktop file not found at $DESKTOP_SRC"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database
    echo "✓ Desktop database updated"
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
    echo "✓ Icon cache updated"
fi

echo ""
echo "$APP_NAME has been installed successfully!"
echo "You can now find it in your application menu."
