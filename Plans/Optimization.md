
## `main.js`

### 🔴 Безопасность
- **TODO:** Убрать `webSecurity: false` — вместо этого реализовать кастомный протокол через `protocol.handle('app', ...)` для безопасной раздачи локальных файлов [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Усилить `isValidPath()` — добавить проверку `path.resolve()` + убедиться, что путь находится внутри разрешённой директории (защита от path traversal атак типа `../../etc/passwd`) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Обернуть `process.env.GTK_USE_PORTAL = '1'` в `if (process.platform === 'linux')` — это Linux-специфичная настройка [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)

### 🟠 Производительность
- **TODO:** Заменить все синхронные `fs.*Sync` (readFileSync, writeFileSync, readdirSync, copyFileSync, unlinkSync, mkdirSync) на `fs.promises.*` — sync-операции блокируют главный процесс Electron [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Переместить `require('url')` и `require('crypto')` из тел IPC-хендлеров на верхний уровень файла — сейчас вызываются при каждом invocation [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)

### 🟡 Баги и устаревший код
- **TODO:** Удалить `mainWindow.on('crashed', ...)` — событие `crashed` удалено в новых версиях Electron; уже есть `webContents.on('render-process-gone')` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Исправить `mainWindow.on('console-message', ...)` → `mainWindow.webContents.on('console-message', ...)` — это событие webContents, не BrowserWindow [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Добавить `app.on('window-all-closed', ...)` хендлер для корректного завершения на Windows/Linux [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Установить `mainWindow = null` внутри `window.on('closed')` для предотвращения утечки памяти [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)

### 🔵 Архитектура
- **TODO:** Использовать аргумент `params` в хендлере `context-menu` для контекстно-зависимого меню (сейчас меню всегда одинаковое вне зависимости от того, что кликнул пользователь) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Переименовать внутреннюю функцию `getConfigPath()` в `getConfigDir()` — она возвращает директорию, а не путь к файлу; конфликтует по смыслу с IPC-хендлером `fs:getConfigPath` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Заменить magic-число `5` в `recent-projects:add` (`projects.slice(0, 5)`) на общую константу [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Пересмотреть набор GPU-флагов — `disable-gpu-*` и `enable-zero-copy` + `ignore-gpu-blocklist` противоречат друг другу; применять только при необходимости и с комментарием-объяснением [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)
- **TODO:** Вынести IPC-хендлеры в отдельные модули: `ipc/fs.js`, `ipc/window.js`, `ipc/recentProjects.js` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f33d1ef2-2230-473d-8544-dab97de0f3b4/main.js)

***

## `preload.js`

### 🔴 Утечки памяти
- **TODO:** Исправить накопление слушателей в `onFilesDropped`, `onContextMenuAction`, `onRenderProcessGone` — каждый вызов добавляет новый `ipcRenderer.on`, не удаляя предыдущий; возвращать функцию-отписку или удалять старый листенер перед добавлением нового [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/ce5ee19f-93f4-4bd4-aac1-9df79c8d2a00/preload.js)

### 🔴 Баги
- **TODO:** Убрать `webUtils:getPathForFile` из IPC и вызывать `webUtils.getPathForFile(file)` прямо в preload — объект `File` не сериализуется через IPC, хендлер в main.js работает некорректно [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/ce5ee19f-93f4-4bd4-aac1-9df79c8d2a00/preload.js)

### 🟠 Безопасность
- **TODO:** Ограничить `removeAllListeners` — сейчас открывает прямой доступ к `ipcRenderer.removeAllListeners` для любого канала; следует принимать только допустимые названия каналов [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/ce5ee19f-93f4-4bd4-aac1-9df79c8d2a00/preload.js)

***

## `renderer.js`

### 🔴 Баги
- **TODO:** Исправить логику дебаунса в `saveConfig()` — `if (this.saveTimeout) return` игнорирует вызовы, пока таймер активен; нужен стандартный паттерн: `clearTimeout` + переназначение таймера, иначе последние изменения могут не сохраниться [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Исправить `detachImageFromFrame` — `img.x = frame.x + (img.x - frame.x)` математически равно `img.x = img.x`, т.е. ничего не делает; нужно правильное преобразование из frame-относительных координат в абсолютные [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Исправить `reloadImage` — Promise из `this.projectManager.getFilesDir().then(...)` присваивается в `const filesDir`, но не awaited и не обрабатывается; нужен `async/await` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Удалить `dragstart` листенер в `_setupEntityEvents` — изображения создаются с `img.draggable = false`, поэтому событие никогда не срабатывает [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Вызывать `_invalidateDimensionCache(id)` при изменении `scale` изображения — сейчас кэш не инвалидируется при масштабировании, из-за чего bounds расчёты могут быть неверными [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)

### 🟠 Производительность
- **TODO:** Перевести позиционирование `.canvas-image` с `left/top` на `transform: translate(x, y)` — CSS transforms аппаратно ускорены и не вызывают layout reflow [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f2ca6c18-1031-47a6-8f2e-e393ecbd7663/style.css)
- **TODO:** Добавить батчинг в `loadAllFrames` по аналогии с `loadAllImages` для консистентности и производительности при большом количестве фреймов [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Заменить `performance.memory` (нестандартный Chrome API) на `process.memoryUsage()` через IPC для надёжного мониторинга памяти [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Убрать вызов `window.gc()` или явно включить флаг `--expose-gc` в main.js — без него вызов молча игнорируется [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)

### 🔵 Архитектура
- **TODO:** Разбить `renderer.js` (60К символов) на ES-модули: `camera.js`, `projectManager.js`, `entityManager.js`, `frameManager.js`, `app.js` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Вынести дублирующийся код открытия проекта из `_openProject`, `_openRecentProject`, `_ensureProjectOpen` в единый метод `_afterProjectOpen(path)` — эти ~10 строк повторяются трижды [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)
- **TODO:** Перенести логику создания проекта из `_createNewProject` в `ProjectManager` класс [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9c4d19dd-321c-4a09-beb5-0ee43661b91c/renderer.js)

***

## `package.json`

- **TODO:** Обновить `electron` с `^28.3.3` до актуальной стабильной версии (34.x) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)
- **TODO:** Добавить `electron-builder` или `electron-forge` для production-сборки [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)
- **TODO:** Добавить отдельный `build`-скрипт — сейчас `start` и `dev` идентичны [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)
- **TODO:** Заполнить поле `author` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)
- **TODO:** Добавить поле `engines` с указанием версии Node.js [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)
- **TODO:** Добавить скрипты `lint` и `test` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/17c4c7c6-b797-42c8-829d-df35fd8495e5/package.json)

***

## `style.css`

- **TODO:** Удалить или использовать CSS-переменную `--accent-hover` — объявлена, но нигде не используется [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f2ca6c18-1031-47a6-8f2e-e393ecbd7663/style.css)
- **TODO:** Изменить `will-change: left, top` на `will-change: transform` для `.canvas-image` — соответствует рекомендуемому подходу после перехода на transform-позиционирование [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f2ca6c18-1031-47a6-8f2e-e393ecbd7663/style.css)
- **TODO:** Вынести magic-значения `.frame-label` (`top: -200px`, `font-size: 150px`) в CSS-переменные с комментарием о причине таких значений [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/f2ca6c18-1031-47a6-8f2e-e393ecbd7663/style.css)

***

## `index.html`

- **TODO:** Добавить `<meta http-equiv="Content-Security-Policy" content="...">` — полное отсутствие CSP в сочетании с `webSecurity: false` в main.js создаёт критический вектор атаки [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/0f413a7b-9ff3-4542-a0a4-1f1fe42396c6/index.html)

***

## Общее / Cross-cutting

- **TODO:** Добавить JSDoc-аннотации или мигрировать на TypeScript для лучшей поддерживаемости классов `Camera`, `ProjectManager`, `EntityManager`, `FrameManager`
- **TODO:** Добавить `.eslintrc` с правилами для Electron-проектов (`plugin:node/recommended`)
- **TODO:** Реализовать стек undo/redo для операций с изображениями и фреймами
- **TODO:** Добавить `electron-updater` для авто-обновлений
- **TODO:** Добавить unit-тесты для изолируемой логики (Camera, ProjectManager)
