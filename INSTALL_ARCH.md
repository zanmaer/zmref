# ZmRef для Arch Linux

## Установка

### Вариант 1: AppImage (Рекомендуется)

1. **Скачайте AppImage**:
   ```bash
   # Файл: ZmRef-1.0.0.AppImage
   ```

2. **Сделайте исполняемым**:
   ```bash
   chmod +x ZmRef-1.0.0.AppImage
   ```

3. **Запустите установку desktop-интеграции**:
   ```bash
   ./setup-desktop.sh
   ```

   Этот скрипт:
   - Скопирует AppImage в `~/opt/zmref/`
   - Установит иконку в `~/.local/share/icons/`
   - Создаст .desktop файл для меню приложений
   - Обновит кэши desktop и иконок

4. **Запустите из меню приложений** или командой:
   ```bash
   ~/opt/zmref/ZmRef-1.0.0.AppImage
   ```

---

### Вариант 2: DEB пакет (через deb2targz)

```bash
# Конвертируйте deb в tar.gz
deb2targz ZmRef-1.0.0.deb

# Распакуйте
tar -xzf ZmRef-1.0.0.tar.gz

# Запустите
./usr/bin/zmref
```

---

### Вариант 3: Прямой запуск из сборки

```bash
# Перейдите в директорию сборки
cd dist/linux-unpacked/

# Запустите
./zmref
```

---

## Зависимости

Для работы ZmRef требуются:

```bash
sudo pacman -S gtk3 libnotify libxss libxtst at-spi2-atk libuuid
```

Или установите все зависимости одним командой:

```bash
sudo pacman -S --needed gtk3 libnotify libxss libxtst at-spi2-atk libuuid nss alsa-lib
```

---

## Удаление

```bash
# Удалите приложение
rm -rf ~/opt/zmref

# Удалите иконку
rm ~/.local/share/icons/hicolor/512x512/apps/zmref.png

# Удалите desktop файл
rm ~/.local/share/applications/zmref.desktop

# Обновите кэши
update-desktop-database ~/.local/share/applications
gtk-update-icon-cache -f ~/.local/share/icons/hicolor
```

---

## Структура сборки

```
dist/
├── ZmRef-1.0.0.AppImage      # Портативная версия
├── ZmRef-1.0.0.deb           # DEB пакет
├── linux-unpacked/           # Распакованная версия
│   ├── zmref                 # Исполняемый файл
│   ├── resources/            # Ресурсы приложения
│   └── lib/                  # Библиотеки
└── build/
    ├── setup-desktop.sh      # Скрипт установки
    ├── install.sh            # Альтернативный скрипт
    └── *.png                 # Иконки
```

---

## Интеграция с системой

После запуска `setup-desktop.sh`:

- ✓ Иконка появится в меню приложений
- ✓ Приложение будет в категории "Графика"
- ✓ Поддержка ассоциации файлов изображений
- ✓ Автоматическое обновление кэшей

---

## Сборка из исходников

```bash
# Установите зависимости
npm install

# Соберите AppImage и DEB
npm run build:linux

# Найдите сборки в dist/
ls dist/
```

---

## Поддержка

- GitHub: https://github.com/zanmaer/zmref
- License: MIT
