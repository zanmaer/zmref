#!/bin/bash

# ZmRef - Post Install Script for Arch Linux
# Run this script after extracting the AppImage to install desktop integration

set -e

APP_NAME="ZmRef"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIMAGE_PATH="$SCRIPT_DIR/ZmRef-1.0.0.AppImage"

# Installation paths
ICON_SRC="$SCRIPT_DIR/resources/app/build/zmref.png"
ICON_DEST="$HOME/.local/share/icons/hicolor/512x512/apps/zmref.png"
DESKTOP_SRC="$SCRIPT_DIR/resources/app/build/zmref.desktop"
DESKTOP_DEST="$HOME/.local/share/applications/zmref.desktop"
APP_DEST="$HOME/opt/zmref/ZmRef-1.0.0.AppImage"

echo "╔════════════════════════════════════════════╗"
echo "║     ZmRef - Desktop Integration Setup     ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME/.local/share/icons/hicolor/512x512/apps"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/opt/zmref"

# Copy AppImage
if [ -f "$APPIMAGE_PATH" ]; then
    echo "📦 Copying AppImage to $HOME/opt/zmref/..."
    cp "$APPIMAGE_PATH" "$APP_DEST"
    chmod +x "$APP_DEST"
    echo "   ✓ AppImage installed"
else
    echo "   ⚠ AppImage not found at $APPIMAGE_PATH"
    echo "   Please run this script from the same directory as the AppImage"
    exit 1
fi

# Copy icon
if [ -f "$ICON_SRC" ]; then
    echo "🖼️  Installing icon..."
    cp "$ICON_SRC" "$ICON_DEST"
    echo "   ✓ Icon installed"
else
    # Try alternative path (extracted from AppImage)
    ICON_SRC="$SCRIPT_DIR/zmref.png"
    if [ -f "$ICON_SRC" ]; then
        cp "$ICON_SRC" "$ICON_DEST"
        echo "   ✓ Icon installed (alternative path)"
    else
        echo "   ⚠ Icon not found"
    fi
fi

# Copy and update desktop file
if [ -f "$DESKTOP_SRC" ]; then
    echo "📄 Installing desktop file..."
    # Update Exec path in desktop file
    sed "s|Exec=zmref|Exec=$APP_DEST|g" "$DESKTOP_SRC" > "$DESKTOP_DEST"
    chmod +x "$DESKTOP_DEST"
    echo "   ✓ Desktop file installed"
else
    # Create desktop file manually
    echo "📄 Creating desktop file..."
    cat > "$DESKTOP_DEST" << EOF
[Desktop Entry]
Name=ZmRef
Comment=Minimalist Reference Image Viewer
Exec=$APP_DEST %U
Terminal=false
Type=Application
Icon=zmref
StartupWMClass=zmref
Categories=Graphics;Viewer;
MimeType=image/png;image/jpeg;image/jpg;image/webp;image/gif;image/svg+xml;
Keywords=reference;images;canvas;organizer;
EOF
    chmod +x "$DESKTOP_DEST"
    echo "   ✓ Desktop file created"
fi

# Update caches
echo ""
echo "🔄 Updating desktop database..."
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    echo "   ✓ Desktop database updated"
else
    echo "   ⚠ update-desktop-database not found"
fi

echo "🔄 Updating icon cache..."
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    echo "   ✓ Icon cache updated"
else
    echo "   ⚠ gtk-update-icon-cache not found"
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║          Installation Complete!            ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "✓ $APP_NAME has been installed to: $HOME/opt/zmref/"
echo "✓ Desktop entry created in application menu"
echo ""
echo "You can now:"
echo "  • Launch from application menu"
echo "  • Run: $APP_DEST"
echo ""
echo "To uninstall:"
echo "  rm -rf $HOME/opt/zmref"
echo "  rm $ICON_DEST"
echo "  rm $DESKTOP_DEST"
echo ""
