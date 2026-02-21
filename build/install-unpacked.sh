#!/bin/bash

# ZmRef - Установка распакованной версии для Arch Linux
# Используйте этот скрипт если AppImage не работает

set -e

APP_NAME="ZmRef"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_SRC="$SCRIPT_DIR/../dist/linux-unpacked"
APP_DEST="$HOME/opt/zmref"

echo "╔════════════════════════════════════════════╗"
echo "║  ZmRef - Установка распакованной версии   ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Проверка источника
if [ ! -f "$APP_SRC/zmref" ]; then
    echo "❌ Файл zmref не найден в $APP_SRC"
    echo "   Убедитесь, что сборка успешна: npm run build:linux"
    exit 1
fi

# Создание директорий
echo "📁 Создание директорий..."
mkdir -p "$APP_DEST"
mkdir -p "$HOME/.local/share/icons/hicolor/512x512/apps"
mkdir -p "$HOME/.local/share/applications"

# Копирование файлов
echo "📦 Копирование файлов..."
cp -r "$APP_SRC/"* "$APP_DEST/"
chmod +x "$APP_DEST/zmref"
echo "   ✓ Файлы скопированы в $APP_DEST"

# Копирование иконки
echo "🖼️  Установка иконки..."
cp "$SCRIPT_DIR/zmref.png" "$HOME/.local/share/icons/hicolor/512x512/apps/zmref.png"
echo "   ✓ Иконка установлена"

# Создание desktop файла
echo "📄 Создание desktop файла..."
cat > "$HOME/.local/share/applications/zmref.desktop" << EOF
[Desktop Entry]
Name=ZmRef
Comment=Minimalist Reference Image Viewer
Exec=$APP_DEST/zmref %U
Terminal=false
Type=Application
Icon=zmref
StartupWMClass=zmref
Categories=Graphics;Viewer;
MimeType=image/png;image/jpeg;image/jpg;image/webp;image/gif;image/svg+xml;
Keywords=reference;images;canvas;organizer;
EOF
chmod +x "$HOME/.local/share/applications/zmref.desktop"
echo "   ✓ Desktop файл создан"

# Обновление кэшей
echo ""
echo "🔄 Обновление кэшей..."
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null && echo "   ✓ Desktop database" || true
fi
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null && echo "   ✓ Icon cache" || true
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║          Установка завершена!             ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "✓ Запуск из меню приложений"
echo "✓ Или командой: $APP_DEST/zmref"
echo ""
echo "Для удаления:"
echo "  rm -rf $APP_DEST"
echo "  rm ~/.local/share/icons/hicolor/512x512/apps/zmref.png"
echo "  rm ~/.local/share/applications/zmref.desktop"
echo ""
