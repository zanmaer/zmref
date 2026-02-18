# AGENTS.md - ZmRef Electron

## Build & Run Commands

```bash
npm install
npm run dev    # Start in development mode
npm start      # Start Electron app
npm run build  # Production build (requires electron-builder)
```

### Lint & Test Commands

```bash
# Lint (requires eslint installed: npm i -D eslint)
npm run lint
npm run lint -- --fix    # Auto-fix issues

# Test (requires jest: npm i -D jest)
npm test
npm test -- --watch      # Watch mode
npm test -- --testPathPattern=filename  # Single test file
```

---

## Code Style

### General Rules
- **Language**: Vanilla JS (ES6+), no frameworks
- **Indentation**: 2 spaces
- **Quotes**: Single quotes preferred
- **Semicolons**: Always use semicolons
- **Line length**: Max 100 characters

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `class Camera`, `class FrameManager` |
| Methods/variables | camelCase | `this.cx`, `saveConfig()` |
| Constants | UPPER_SNAKE_CASE | `IMAGE_EXTENSIONS` |
| Private methods | prefix underscore | `_handleResize()` |

### ES6 Class Structure
```javascript
class MyClass {
  constructor(param) {
    this.prop = param;
    this._privateState = null;
  }

  publicMethod() {
    return this._privateMethod();
  }

  _privateMethod() {
    return this.prop;
  }
}
```

---

## Architecture

```
main.js      # Electron main: IPC handlers, window, context menus
preload.js   # contextBridge: secure API to renderer
renderer.js  # App: Camera, ProjectManager, EntityManager, FrameManager, App
index.html   # DOM structure
style.css    # Styles with CSS variables
config.json  # Project config
```

### Key Classes (renderer.js)
| Class | Responsibility |
|-------|----------------|
| **Camera** | Pan/zoom math, coordinate transforms |
| **ProjectManager** | File I/O, config loading/saving, debounced saves |
| **EntityManager** | Image lifecycle: create, drag, delete, z-order |
| **FrameManager** | Frame creation, resize (8 handles), lock |
| **App** | Event coordination, UI state, shortcuts |

---

## IPC Communication

### Main Process (main.js)
```javascript
ipcMain.handle('channel:name', async (event, ...args) => {
  try {
    if (!args[0]) throw new Error('Invalid argument');
    const result = await doWork(args);
    return { success: true, data: result };
  } catch (error) {
    console.error('[MAIN] channel:name error:', error.message);
    return { success: false, error: error.message };
  }
});
```

### Preload (preload.js)
```javascript
contextBridge.exposeInMainWorld('api', {
  channel: (...args) => ipcRenderer.invoke('channel:name', ...args),
  onEvent: (callback) => ipcRenderer.on('event:name', (e, d) => callback(d)),
  removeEvent: (channel) => ipcRenderer.removeAllListeners(channel)
});
```

### Key IPC Channels
| Channel | Direction | Purpose |
|---------|-----------|---------|
| `dialog:openDirectory` | renderer→main | Open folder picker |
| `dialog:openFiles` | renderer→main | Open file picker |
| `fs:readFile`, `fs:writeFile` | renderer→main | File I/O |
| `path:join`, `path:basename` | renderer→main | Path utilities |
| `window:minimize/maximize/close` | renderer→main | Window controls |
| `recent-projects:get/add/remove` | renderer→main | Recent projects |
| `files-dropped` | main→renderer | File drop notification |

---

## Common Patterns

### Debounced Save
```javascript
saveConfig() {
  if (this.saveTimeout) return;
  this.saveTimeout = setTimeout(async () => {
    try {
      await window.api.fs.writeFile(this.configPath, JSON.stringify(this.config, null, 2));
    } catch (error) {
      console.error('[ProjectManager] Save failed:', error);
    } finally {
      this.saveTimeout = null;
    }
  }, 500);
}
```

### Zoom-to-Cursor
```javascript
zoomToPoint(delta, screenX, screenY, viewportRect) {
  const mouseX = screenX - viewportRect.left;
  const mouseY = screenY - viewportRect.top;
  const zoomFactor = delta > 0 ? 0.9 : 1.1;
  const newZoom = Math.max(this.minZoom, Math.min(this.maxZoom, this.zoom * zoomFactor));
  if (newZoom === this.zoom) return;
  const worldX = (mouseX - this.cx) / this.zoom;
  const worldY = (mouseY - this.cy) / this.zoom;
  this.zoom = newZoom;
  this.cx = mouseX - worldX * this.zoom;
  this.cy = mouseY - worldY * this.zoom;
}
```

---

## Security

- **Always**: `contextIsolation: true`
- **Never**: `nodeIntegration: true`
- **Validate**: All IPC inputs in main process
- **WebSecurity**: `false` only for `file://` protocol

---

## Debugging

### Logging Prefix
| Prefix | File |
|--------|------|
| `[MAIN]` | main.js |
| `[RENDERER]` | renderer.js |
| `[Camera]`, `[ProjectManager]` | Specific classes |

### DevTools
- Open: `Ctrl+Shift+I`
- Check console for `[RENDERER]` logs

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Space (hold) | Pan mode |
| Delete/Backspace | Delete selected |
| Ctrl+0 | Reset zoom 100% |
| Mouse wheel | Zoom at cursor |
| Right-click | Context menu |
