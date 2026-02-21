# AGENTS.md - ZmRef Electron

## Build & Run Commands

```bash
npm install        # Install dependencies
npm run dev        # Start in development mode (alias: npm start)
npm run build      # Build production app with electron-builder
npm run lint       # No linter configured (echo placeholder)
npm run test       # No tests configured (echo placeholder)
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
- **Logging**: Use `[PREFIX]` format for all console methods

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `Camera`, `FrameManager` |
| Methods/variables | camelCase | `saveConfig()`, `_isExecuting` |
| Constants | UPPER_SNAKE_CASE | `IMAGE_EXTENSIONS`, `CONSTANTS` |
| Private methods | underscore prefix | `_handleResize()` |
| CSS classes | kebab-case | `.canvas-image` |
| Logging prefix | bracket uppercase | `[App]`, `[Camera]` |

### Import Order
1. Electron modules (electron, path, fs)
2. Node.js built-ins (crypto, url)
3. External dependencies (none currently)
4. Local modules (none currently)

### Constants Pattern
Group constants in a frozen object at module top:
```javascript
const CONSTANTS = Object.freeze({
  DEFAULT_ZOOM: 1,
  MIN_ZOOM: 0.05,
  MAX_ZOOM: 5,
  // ...
});
```

### File Structure
```
main.js      # Electron main: IPC handlers, window, menus
preload.js   # contextBridge API to renderer (100 lines)
renderer.js  # All app classes (~2000 lines)
index.html   # DOM structure
style.css    # Styles with CSS variables
package.json # Project config, scripts
```

---

## Architecture

### Key Classes (renderer.js)
| Class | Responsibility |
|-------|----------------|
| **Camera** | Pan/zoom math, coordinate transforms, view state |
| **ProjectManager** | File I/O, config loading/saving, recent projects |
| **EntityManager** | Image lifecycle: create, drag, delete, offscreen unload |
| **FrameManager** | Frame creation, resize handles, lock state |
| **App** | Event coordination, UI state, shortcuts, memory monitoring |

### Memory Management
- Use offscreen image unloading for large projects (>100 images)
- Monitor heap via `window.performance.memory`
- Trigger cleanup at 70% threshold (`MEMORY_WARNING_THRESHOLD`)
- Always clear image `src` before removing elements
- Call `window.gc()` after clearing entities (if available)

---

## IPC Communication

### Pattern: Main (main.js)
```javascript
ipcMain.handle('channel:name', async (event, ...args) => {
  try {
    if (!isValidPath(args[0])) throw new Error('Invalid argument');
    const result = await doWork(args);
    return { success: true, data: result };
  } catch (error) {
    console.error('[IPC] channel:name error:', error.message);
    return { success: false, error: error.message };
  }
});
```

### Pattern: Preload (preload.js)
```javascript
contextBridge.exposeInMainWorld('api', {
  channel: (...args) => ipcRenderer.invoke('channel:name', ...args),
  onEvent: (callback) => {
    const handler = (e, d) => callback(d);
    ipcRenderer.on('event:name', handler);
    listenersMap.set('event:name', handler);
  },
  removeAllListeners: (channel) => {
    if (ALLOWED_CHANNELS.includes(channel) && listenersMap.has(channel)) {
      ipcRenderer.removeListener(channel, listenersMap.get(channel));
      listenersMap.delete(channel);
    }
  }
});
```

### Key IPC Channels
| Channel | Direction | Purpose |
|---------|-----------|---------|
| `dialog:openDirectory` | renderer→main | Open folder picker |
| `dialog:openFiles` | renderer→main | Open file picker |
| `fs:readFile`, `fs:writeFile`, `fs:deleteFile` | renderer→main | File I/O |
| `window:minimize/maximize/close` | renderer→main | Window controls |
| `recent-projects:*` | renderer→main | Recent projects management |
| `files-dropped` | main→renderer | File drop notification |
| `render-process-gone` | main→renderer | Crash notification |

---

## Security
- **Always**: `contextIsolation: true`, `nodeIntegration: false`, `webSecurity: true`
- **Never**: Enable `nodeIntegration` in renderer
- **Validate**: All IPC inputs in main process using `isValidPath()` function
- **Allowlist**: Only expose specific channels in preload.js (see `ALLOWED_CHANNELS`)
- **Avoid**: `eval()`, `new Function()`, dynamic code execution

---

## Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| Space (hold) | Pan mode |
| Delete/Backspace | Delete selected |
| Ctrl+0 | Reset zoom 100% |
| Ctrl+A | Select all |
| Ctrl+Z / Ctrl+Shift+Z | Undo/Redo (planned) |
| Escape | Clear selection |
| Mouse wheel | Zoom at cursor |
| Right-click | Context menu |

---

## Common Tasks

### Adding a New IPC Channel
1. Add handler in `main.js` with validation and error handling
2. Add API method in `preload.js` under appropriate namespace
3. Call from `renderer.js` via `window.api.channel()`
4. Add channel to `ALLOWED_CHANNELS` in preload if event-based

### Adding a New Class
1. Follow ES6 class pattern with constructor
2. Add logging prefix to console methods: `[ClassName]`
3. Document in Architecture section of this file
4. Consider dependency injection (e.g., camera, projectManager)

### Debouncing Config Saves
Use debounce pattern for frequent config updates:
```javascript
saveTimeout = setTimeout(async () => {
  // save logic
}, CONSTANTS.DEBOUNCE_DELAY_MS);
```

---

## Development Tips

### Debugging
- Check console output with `[MAIN]`, `[RENDERER]`, `[App]` prefixes
- Use `window.performance.memory` to monitor heap usage
- Render process crashes trigger recovery mode automatically

### GPU Flags (main.js)
Current flags to reduce GPU memory:
```javascript
app.commandLine.appendSwitch('disable-gpu-compositing');
app.commandLine.appendSwitch('disable-gpu-rasterization');
// ... others
```

### Canvas Size
- Default: 5000x5000px (defined in style.css)
- Position entities using `transform: translate()` not left/top
- Use `will-change: transform` only during drag operations
