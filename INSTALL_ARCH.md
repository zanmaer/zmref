# ZmRef для Arch Linux

## Быстрый старт

### Для Arch Linux (Рекомендуется)

**AppImage не работает на Arch без FUSE!** Используйте распакованную версию:

```bash
# 1. Установите FUSE (если хотите использовать AppImage)
sudo pacman -S fuse2

# 2. ИЛИ используйте распакованную версию (рекомендуется)
cd "/path/to/zmref/build"
./install-unpacked.sh
```

---

## Вариант 1: Распакованная версия (Рекомендуется для Arch)

Этот вариант работает без FUSE и интегрируется в систему.

```bash
# Запустите скрипт установки
cd build/
./install-unpacked.sh
```

**Что делает скрипт:**
- Копирует файлы в `~/opt/zmref/`
- Устанавливает иконку
- Создаёт .desktop файл в меню приложений
- Обновляет кэши

**Запуск:**
- Из меню приложений
- Или командой: `~/opt/zmref/zmref`

---

## Вариант 2: AppImage (Требует FUSE)

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
