## 🔴 Новые баги (появились при правках)

### `main.js` — дублирование обработчиков
Выглядит как copy-paste при добавлении новых хендлеров поверх старых. В `createWindow()` зарегистрированы **дважды**:
- `will-navigate` — 2 раза на `webContents`
- `render-process-gone` — 2 раза на `webContents`
- `console-message` — 1 раз на `webContents` (верно) + 1 раз на `mainWindow` (неверно)
- `drop-files` — 2 раза на `mainWindow`
- `mainWindow.on('crashed', ...)` — всё ещё присутствует (deprecated) [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9b8c1ab3-6067-46c0-9497-a6cea48722e2/main.js)

**Нужно:** Удалить все дублирующиеся и устаревшие хендлеры ниже `mainWindow.on('closed', ...)`.

### `main.js` — `protocol.handle` внутри `createWindow()`
На macOS `createWindow()` может вызываться повторно (по клику на иконку в Dock при закрытом окне) — второй вызов `protocol.handle('app', ...)` бросит ошибку. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9b8c1ab3-6067-46c0-9497-a6cea48722e2/main.js)

**Нужно:** Вынести `protocol.handle(...)` за пределы `createWindow()`, внутрь `app.whenReady().then(...)`.

### `main.js` — слабая защита от path traversal в `isValidPath`
Текущая логика: `if (normalizedPath.includes('..'))` — но `path.normalize('/home/user/../../../../etc/passwd')` возвращает `/etc/passwd` (без `..`!), и проверка будет пропущена. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/9b8c1ab3-6067-46c0-9497-a6cea48722e2/main.js)

**Нужно:** Убрать проверку через `includes('..')` и **всегда** сравнивать `path.resolve(filePath)` с допустимым базовым путём.

***

## 🟠 Оставшиеся нерешённые проблемы

### `preload.js`
- `webUtils:getPathForFile` всё ещё роутится через IPC — объект `File` не сериализуется через IPC и хендлер в `main.js` не получит файл корректно. Нужно вызывать `webUtils.getPathForFile()` **прямо в preload**, без IPC [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/baa9862b-6642-41c3-a374-7ec6a716a232/preload.js)

### `renderer.js`
- `_invalidateDimensionCache(id)` не вызывается при изменении `scale` → bounds-расчёты могут быть неверными [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/4faf3f87-0cf7-4c58-9f62-d76bf61e0127/renderer.js)
- `bringToFront` содержит баг: `const newZ = Math.min(maxZ + 1, 10)` — `Math.min` с 10 ограничивает z-index, новые фреймы не смогут подняться выше 10, но это число совпадает с `zIndex: 10` изображений, что создаст визуальный конфликт [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/4faf3f87-0cf7-4c58-9f62-d76bf61e0127/renderer.js)
- `left/top` позиционирование изображений всё ещё не переведено на `transform: translate()` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/4faf3f87-0cf7-4c58-9f62-d76bf61e0127/renderer.js)

### `package.json`
- `electron` по-прежнему `^28.3.3` — версия 28 вышла из LTS, рекомендуется обновить до 34.x [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/d5fcd63f-7ec3-4de8-b989-b16bbfd95d7b/package.json)
