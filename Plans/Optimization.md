
## Что произошло

Флаг `use-gl=desktop` форсирует desktop OpenGL, но система поддерживает только EGL-реализации:
```
allowed: [(gl=egl-angle,angle=default), (gl=egl-gles2,angle=none)]
requested: (gl=none, angle=none)  ← результат несовместимого флага
```
GPU-процесс падает три раза подряд, после чего Chromium переключается в полный software mode — что хуже, чем было изначально.

***

## Исправление `main.js`

Убрать оба флага которые я добавил в прошлый раз, они несовместимы с этой системой:

```js
// УБРАТЬ — вызывают падение GPU-процесса на EGL-системах:
// app.commandLine.appendSwitch('disable-vulkan');
// app.commandLine.appendSwitch('use-gl', 'desktop');
```

Итоговый список флагов должен выглядеть так:

```js
app.commandLine.appendSwitch('disable-accelerated-video-decode');
app.commandLine.appendSwitch('disable-gpu-memory-buffer-compositor-resources');
app.commandLine.appendSwitch('disable-accelerated-2d-canvas');
```

***

## Финальная картина

Три предыдущих флага (`disable-gpu-compositing`, `disable-gpu-rasterization`, `use-gl=desktop`) — **все убрать**. Реальную проблему с tile memory решают изменения в CSS и JS, а не флаги GPU:

- `#canvas` размером 20000×20000px без `will-change` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/02c1237a-9f01-4791-a7cb-5af829e02a73/style.css)
- rAF-батчинг в `_handleWheel` и `_updatePan` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/ce9c3755-4fd7-44f1-bb22-965b902d5f7b/renderer.js)
- `will-change: transform` только на `.canvas-image.is-dragging` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/153923199/02c1237a-9f01-4791-a7cb-5af829e02a73/style.css)

Система сама выберет оптимальный GL бэкенд (`egl-angle` или `egl-gles2`) без принудительных флагов.
