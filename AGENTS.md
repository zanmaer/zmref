# AGENTS.md - ZmRef Electron Project

## Build & Run Commands

```bash
npm install
npm run dev    # Start in development mode (same as npm start)
npm start      # Start Electron app
```

### Lint Commands (ESLint required)

```bash
# Add to package.json first: "lint": "eslint ."
npm run lint
npm run lint -- --fix    # Auto-fix issues
```

### Test Commands (Jest required)

```bash
# Add to package.json: "test": "jest", "test:watch": "jest --watch"
npm test                    # Run all tests
npm test -- --watch         # Watch mode
npm test -- --testPathPattern=filename  # Single test file
```

### Production Build

```bash
# Install electron-builder first: npm install --save-dev electron-builder
npm run build               # Build for production (add script to package.json)
```

---

## Code Style

### General Rules
- **Language**: Vanilla JS (ES6+), no frameworks
- **Indentation**: 2 spaces
- **Quotes**: Single quotes preferred
- **Semicolons**: Always use semicolons
- **Line length**: Max 100 characters (soft limit)

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `class Camera`, `class FrameManager` |
| Methods/variables | camelCase | `this.cx`, `saveConfig()`, `handleDrop()` |
| Constants | UPPER_SNAKE_CASE | `DEBOUNCE_DELAY_MS`, `IMAGE_EXTENSIONS` |
| DOM IDs | lowercase with hyphens | `btn-open-project`, `canvas-viewport` |
| CSS classes | lowercase with hyphens | `.frame-container`, `.resize-handle` |
| Private methods | prefix with underscore | `_handleResize()`, `_cleanupEvents()` |

### ES6 Class Structure
```javascript
class MyClass {
  constructor(param) {
    this.prop = param;
    this._privateState = null;
  }

  // Public methods first
  publicMethod() {
    return this._privateMethod();
  }

  // Private methods after public
  _privateMethod() {
    return this.prop;
  }
}
```

### Error Handling
- Always wrap IPC calls in try/catch
- Return error objects: `{ success: false, error: message }`
- Never expose internal errors to renderer
- Log errors with context prefix: `console.error('[ClassName] message:', error)`

---

## Architecture

```
main.js       # Electron main process: IPC handlers, window config, context menus
preload.js    # contextBridge: secure API exposure to renderer
renderer.js   # App logic: Camera, ProjectManager, EntityManager, FrameManager, App
index.html    # DOM structure with data-* attributes
style.css     # Styles with GPU optimizations, CSS variables
config.json   # Project config: canvas state, images[], frames[]
```

### Key Classes (renderer.js)

| Class | Responsibility |
|-------|----------------|
| **Camera** | Pan/zoom math, coordinate transforms, CSS transform application |
| **ProjectManager** | File I/O, config loading/saving, debounced saves |
| **EntityManager** | Image lifecycle: create, drag, delete, z-ordering |
| **FrameManager** | Frame creation, resize (8 handles), drag, lock state, names |
| **App** | Event coordination, UI state, keyboard shortcuts |

---

## IPC Communication

### Main Process Pattern (main.js)
```javascript
ipcMain.handle('channel:name', async (event, ...args) => {
  try {
    // Validate inputs
    if (!args[0]) throw new Error('Invalid argument');

    const result = await doWork(args);
    return { success: true, data: result };
  } catch (error) {
    console.error('[MAIN] channel:name error:', error.message);
    return { success: false, error: error.message };
  }
});
```

### Preload Pattern (preload.js)
```javascript
contextBridge.exposeInMainWorld('api', {
  // Invoke pattern (request/response)
  channel: (...args) => ipcRenderer.invoke('channel:name', ...args),

  // Event pattern (main → renderer)
  onEvent: (callback) => ipcRenderer.on('event:name', (e, d) => callback(d)),

  // Cleanup events
  removeEvent: (channel) => ipcRenderer.removeAllListeners(channel)
});
```

### Available IPC Channels
| Channel | Direction | Purpose |
|---------|-----------|---------|
| `dialog:openDirectory` | renderer→main | Open folder picker |
| `dialog:openFiles` | renderer→main | Open file picker |
| `fs:readFile` | renderer→main | Read file contents |
| `fs:writeFile` | renderer→main | Write file contents |
| `fs:copyFile` | renderer→main | Copy file to project |
| `fs:mkdir` | renderer→main | Create directory |
| `fs:exists` | renderer→main | Check file exists |
| `fs:getFilesDir` | renderer→main | Get project files path |
| `path:join` | renderer→main | Join path segments |
| `path:basename` | renderer→main | Get filename |
| `path:extname` | renderer→main | Get file extension |
| `path:toFileURL` | renderer→main | Convert path to file:// URL |
| `window:minimize` | renderer→main | Minimize window |
| `window:maximize` | renderer→main | Toggle maximize |
| `window:close` | renderer→main | Close window |
| `files-dropped` | main→renderer | File drop notification |
| `context-menu-action` | main→renderer | Context menu selection |

---

## Common Patterns

### Debounced Save (ProjectManager)
```javascript
saveTimeout = null;

saveConfig() {
  if (this.saveTimeout) return;
  this.saveTimeout = setTimeout(async () => {
    try {
      const data = JSON.stringify(this.config, null, 2);
      await window.api.fs.writeFile(this.configPath, data);
    } catch (error) {
      console.error('[ProjectManager] Save failed:', error);
    } finally {
      this.saveTimeout = null;
    }
  }, 500);
}
```

### Event Listener Cleanup
```javascript
setupEvents(element) {
  const handler = (e) => { /* ... */ };
  element.addEventListener('event', handler);
  element._cleanup = () => {
    element.removeEventListener('event', handler);
    delete element._cleanup;
  };
}

// Call cleanup when removing elements
if (element._cleanup) element._cleanup();
```

### Zoom-to-Cursor (Camera)
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

### Frame Resize (8-direction handles)
```javascript
// Handles: n, s, e, w, ne, nw, se, sw
// Calculate new position/size based on handle direction
_handleResize(handle, dx, dy, frame) {
  const minSize = 50;
  let { x, y, width, height } = frame;

  if (handle.includes('e')) width = Math.max(minSize, width + dx);
  if (handle.includes('w')) { width = Math.max(minSize, width - dx); x += dx; }
  if (handle.includes('s')) height = Math.max(minSize, height + dy);
  if (handle.includes('n')) { height = Math.max(minSize, height - dy); y += dy; }

  return { x, y, width, height };
}
```

### Screen-to-Canvas Coordinate Transform
```javascript
screenToCanvas(screenX, screenY) {
  return {
    x: (screenX - this.cx) / this.zoom,
    y: (screenY - this.cy) / this.zoom
  };
}
```

---

## Security

- **Always**: `contextIsolation: true` in webPreferences
- **Never**: `nodeIntegration: true` in webPreferences
- **Validate**: All IPC inputs in main process before use
- **WebSecurity**: Set to `false` only for local file loading (`file://` protocol)

---

## Debugging

### Logging Convention
| Prefix | Used By |
|--------|---------|
| `[MAIN]` | main.js |
| `[RENDERER]` | renderer.js |
| `[IPC]` | IPC communication |
| `[Camera]` | Camera class |
| `[ProjectManager]` | ProjectManager class |
| `[EntityManager]` | EntityManager class |
| `[FrameManager]` | FrameManager class |

### DevTools
- Open: `Ctrl+Shift+I` (Windows/Linux) or `Cmd+Opt+I` (macOS)
- Console: Check for `[RENDERER]` logs
- Application tab: View localStorage, sessionStorage

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Space (hold) | Pan mode (drag canvas) |
| Delete / Backspace | Delete selected image or frame |
| Ctrl+0 | Reset zoom to 100% |
| Mouse wheel | Zoom in/out at cursor |
| Right-click | Open context menu |
| Ctrl+A | Select all (future) |
| Ctrl+S | Save project (future) |

---

## CSS Variables (style.css)

```css
:root {
  --bg-primary: #1a1a1a;
  --bg-secondary: #252525;
  --bg-tertiary: #333333;
  --text-primary: #e0e0e0;
  --text-secondary: #888888;
  --accent: #4a4a4a;
  --border: #444444;
  --handle: #666666;
  --handle-hover: #888888;
}
```

---

## Future Improvements

- Image scaling/resizing with handles
- Additional keyboard shortcuts (Ctrl+S, Ctrl+A)
- Zoom presets (50%, 100%, 200%)
- Frame color coding
- Image opacity control
- Multi-select with Shift+Click
