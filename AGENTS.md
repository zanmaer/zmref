# AGENTS.md - ZmRef Electron

## Build & Run Commands
```bash
npm install        # Install dependencies
npm run dev       # Start in development mode
npm start         # Start Electron app
npm run lint      # Run JavaScript linting (if available)
```
**Note**: No test suite exists. When adding tests, use Jest and place in `test/` directory.

---

## Code Style

### General Rules
- **Language**: Vanilla JavaScript (ES6+), no frameworks
- **Indentation**: 2 spaces (no tabs)
- **Quotes**: Single quotes preferred
- **Semicolons**: Always use semicolons
- **Line length**: Max 100 characters

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `Camera`, `FrameManager` |
| Methods/variables | camelCase | `saveConfig()`, `_isExecuting` |
| Constants | UPPER_SNAKE_CASE | `IMAGE_EXTENSIONS` |
| Private methods | underscore prefix | `_handleResize()` |
| CSS classes | kebab-case | `.canvas-image` |

### Import Order
1. Node.js built-ins (electron, path, fs)
2. External dependencies
3. Local modules

### File Structure
```
main.js     # Electron main: IPC, window, menus
preload.js  # contextBridge API to renderer
renderer.js # All app classes
index.html  # DOM structure
style.css   # Styles with CSS variables
```

### Error Handling
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

### Logging Prefix
| Prefix | File |
|--------|------|
| `[MAIN]` | main.js |
| `[RENDERER]` | renderer.js |
| `[Camera]` | Camera class |
| `[EntityManager]` | EntityManager class |

---

## Architecture

### Key Classes (renderer.js)
| Class | Responsibility |
|-------|----------------|
| **App** | Event coordination, UI state, shortcuts, memory monitoring |
| **Camera** | Pan/zoom math, coordinate transforms |
| **ProjectManager** | File I/O, config loading/saving |
| **EntityManager** | Image lifecycle: create, drag, delete, offscreen unloading |
| **FrameManager** | Frame creation, resize handles, lock state |

### Memory Management
- Use offscreen image unloading for large projects (>100 images)
- Monitor heap via `window.performance.memory`
- Trigger cleanup at 70% threshold
- Always clear image `src` before removing elements

---

## IPC Communication

### Main (main.js)
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
  removeAllListeners: (channel) => ipcRenderer.removeAllListeners(channel)
});
```

### Key IPC Channels
| Channel | Direction | Purpose |
|---------|-----------|---------|
| `dialog:openDirectory` | renderer→main | Open folder picker |
| `dialog:openFiles` | renderer→main | Open file picker |
| `fs:readFile`, `fs:writeFile`, `fs:deleteFile` | renderer→main | File I/O |
| `window:minimize/maximize/close` | renderer→main | Window controls |
| `recent-projects:*` | renderer→main | Recent projects |
| `files-dropped` | main→renderer | File drop notification |
| `render-process-gone` | main→renderer | Crash notification |

---

## Security
- **Always**: `contextIsolation: true`, `nodeIntegration: false`
- **Never**: Enable `nodeIntegration` in renderer
- **Validate**: All IPC inputs in main process (use `isValidPath()`)
- **Avoid**: `eval()`, `new Function()`, dynamic code execution

---

## Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| Space (hold) | Pan mode |
| Delete/Backspace | Delete selected |
| Ctrl+0 | Reset zoom 100% |
| Ctrl+A | Select all |
| Ctrl+Z / Ctrl+Shift+Z | Undo/Redo |
| Escape | Clear selection |
| Mouse wheel | Zoom at cursor |
| Right-click | Context menu |

---

## Common Tasks

### Adding a New IPC Channel
1. Add handler in `main.js`
2. Add API method in `preload.js`
3. Call from `renderer.js` via `window.api.channel()`

### Adding a New Class
1. Follow ES6 class pattern with constructor
2. Add logging prefix to methods
3. Document in Architecture section
