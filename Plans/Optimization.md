

**`main.js`** — убрать только два самых агрессивных флага, остальные оставить:
```js
// УБРАТЬ:
app.commandLine.appendSwitch('disable-gpu-compositing');
app.commandLine.appendSwitch('disable-gpu-rasterization');

// ОСТАВИТЬ — они не влияют на плавность трансформов:
app.commandLine.appendSwitch('disable-accelerated-video-decode');
app.commandLine.appendSwitch('disable-gpu-memory-buffer-compositor-resources');
app.commandLine.appendSwitch('disable-accelerated-2d-canvas');

// ДОБАВИТЬ — отключает Vulkan, использует стабильный desktop OpenGL:
app.commandLine.appendSwitch('disable-vulkan');
app.commandLine.appendSwitch('use-gl', 'desktop');
```

**`style.css`** — НЕ добавлять `will-change` на `#canvas`. Вместо этого `contain`:
```css
#canvas {
    position: absolute;
    width: 20000px;
    height: 20000px;
    transform-origin: 0 0;
    contain: layout style; /* ← ограничивает paint, не pre-rasterizes всё */
    /* will-change: transform — НЕ ставить */
}
```

**`renderer.js`** — rAF-батчинг оставить, он корректен и нужен.

***

## Почему это работает

| Ситуация | Поведение Chromium |
|---|---|
| `disable-gpu-compositing` + что угодно | Software render, дёрганность |
| GPU включён + `will-change` на 20000px канвасе | Pre-rasterize всего → tile OOM |
| GPU включён + **без** `will-change` на канвасе | GPU compositing только для viewport → плавно и без OOM |

Без `will-change` `transform` всё равно выполняется через GPU compositor — браузер просто не пытается заранее растеризовать весь 20000×20000px канвас, а обрабатывает только видимую область.
