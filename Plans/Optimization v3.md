## `tile memory limits exceeded` — причина и решение

Это ошибка Chromium-рендерера: GPU не хватает памяти для тайлов при масштабировании. В твоём коде **три причины** этой проблемы, действующие одновременно.

### Причина 1 — `will-change: transform` на каждом изображении [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/6c62b6de-8354-4a76-b994-82fde369bf50/style.css)
```css
/* style.css — ПРОБЛЕМА */
.canvas-image {
    will-change: transform; /* ← каждое изображение = отдельный GPU-слой */
}
```
`will-change: transform` на каждом элементе заставляет Chromium выделять отдельный compositing layer под каждое изображение. Если на канвасе 50+ картинок — это 50+ GPU-слоёв, каждый из которых требует тайловой памяти.

**TODO:** Убрать `will-change: transform` из `.canvas-image` в CSS. Применять его только через JS-класс `.is-dragging` во время активного перетаскивания — добавлять в `_startDrag()` и убирать в `endDrag()`.

### Причина 2 — фоновая сетка на масштабируемом канвасе [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/6c62b6de-8354-4a76-b994-82fde369bf50/style.css)
```css
/* style.css — ПРОБЛЕМА */
#canvas {
    background-image: linear-gradient(...) /* ← масштабируется вместе с канвасом */
    background-size: 50px 50px;
    will-change: transform;
}
```
`#canvas` трансформируется через `scale()`, и `background-image` масштабируется вместе с ним. При zoom-out до `0.005` Chromium должен тайлировать огромную логическую область. При zoom-in — тайлы становятся гигантскими физически.

**TODO:** Вынести фоновую сетку из `#canvas` в отдельный `#grid-overlay` — фиксированный элемент поверх viewport, который не трансформируется, а визуально обновляется через JS при изменении камеры (`backgroundPosition` + `backgroundSize` от zoom).

### Причина 3 — `#canvas` не имеет явных размеров [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/6c62b6de-8354-4a76-b994-82fde369bf50/style.css)
Chromium не знает границ канваса и вынужден выделять тайлы под неопределённо большую область.

**TODO:** Добавить фиксированные большие, но конечные размеры `#canvas` (например, `width: 100000px; height: 100000px`) вместо авторазмера. Это даст Chromium чёткую границу тайлирования.


## 🟠 Оставшиеся проблемы

- `webUtils:getPathForFile` всё ещё идёт через IPC — объект `File` не сериализуется [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/e00ac8df-3445-428c-9637-b5aa544e0e9f/preload.js)
- `will-change: left, top` → исправлено на `will-change: transform` в CSS, но сам переход позиционирования с `left/top` на `transform: translate()` для изображений не сделан [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/374d2cc9-9e0e-4a05-af10-8ab4f7d29978/renderer.js)
- `_invalidateDimensionCache` не вызывается при изменении `scale` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/374d2cc9-9e0e-4a05-af10-8ab4f7d29978/renderer.js)
- `electron` по-прежнему `^28.3.3` в `package.json` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/ee6af379-665b-4db3-8e51-b5d69723cb63/package.json)
