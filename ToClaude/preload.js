const { contextBridge, ipcRenderer, webUtils } = require('electron');

const ALLOWED_CHANNELS = [
  'files-dropped',
  'context-menu-action',
  'render-process-gone'
];

const listenersMap = new Map();

contextBridge.exposeInMainWorld('api', {
  dialog: {
    openDirectory: () => ipcRenderer.invoke('dialog:openDirectory'),
    openFiles: () => ipcRenderer.invoke('dialog:openFiles')
  },
  
  fs: {
    readDir: (dirPath) => ipcRenderer.invoke('fs:readDir', dirPath),
    exists: (filePath) => ipcRenderer.invoke('fs:exists', filePath),
    mkdir: (dirPath) => ipcRenderer.invoke('fs:mkdir', dirPath),
    copyFile: (src, dest) => ipcRenderer.invoke('fs:copyFile', src, dest),
    readFile: (filePath) => ipcRenderer.invoke('fs:readFile', filePath),
    writeFile: (filePath, content) => ipcRenderer.invoke('fs:writeFile', filePath, content),
    deleteFile: (filePath) => ipcRenderer.invoke('fs:deleteFile', filePath),
    getFilesDir: (projectPath) => ipcRenderer.invoke('fs:getFilesDir', projectPath),
    getConfigPath: (projectPath) => ipcRenderer.invoke('fs:getConfigPath', projectPath)
  },
  
  path: {
    join: (...args) => ipcRenderer.invoke('path:join', ...args),
    basename: (filePath) => ipcRenderer.invoke('path:basename', filePath),
    extname: (filePath) => ipcRenderer.invoke('path:extname', filePath),
    toFileURL: (filePath) => ipcRenderer.invoke('path:toFileURL', filePath)
  },
  
  crypto: {
    randomUUID: () => ipcRenderer.invoke('crypto:randomUUID')
  },

  webUtils: {
    getPathForFile: (file) => {
      if (!file) return '';
      return webUtils.getPathForFile(file);
    }
  },
  
  window: {
    minimize: () => ipcRenderer.invoke('window:minimize'),
    maximize: () => ipcRenderer.invoke('window:maximize'),
    close: () => ipcRenderer.invoke('window:close'),
    isMaximized: () => ipcRenderer.invoke('window:isMaximized')
  },
  
  recentProjects: {
    get: () => ipcRenderer.invoke('recent-projects:get'),
    add: (projectPath) => ipcRenderer.invoke('recent-projects:add', projectPath),
    validate: () => ipcRenderer.invoke('recent-projects:validate'),
    remove: (projectPath) => ipcRenderer.invoke('recent-projects:remove', projectPath)
  },

  shell: {
    showItemInFolder: (filePath) => ipcRenderer.invoke('shell:showItemInFolder', filePath)
  },
  
  onFilesDropped: (callback) => {
    if (listenersMap.has('files-dropped')) {
      ipcRenderer.removeListener('files-dropped', listenersMap.get('files-dropped'));
    }
    const handler = (event, paths) => callback(paths);
    ipcRenderer.on('files-dropped', handler);
    listenersMap.set('files-dropped', handler);
  },
  
  onContextMenuAction: (callback) => {
    if (listenersMap.has('context-menu-action')) {
      ipcRenderer.removeListener('context-menu-action', listenersMap.get('context-menu-action'));
    }
    const handler = (event, action) => callback(action);
    ipcRenderer.on('context-menu-action', handler);
    listenersMap.set('context-menu-action', handler);
  },

  onRenderProcessGone: (callback) => {
    if (listenersMap.has('render-process-gone')) {
      ipcRenderer.removeListener('render-process-gone', listenersMap.get('render-process-gone'));
    }
    const handler = (event, details) => callback(details);
    ipcRenderer.on('render-process-gone', handler);
    listenersMap.set('render-process-gone', handler);
  },

  removeAllListeners: (channel) => {
    if (ALLOWED_CHANNELS.includes(channel)) {
      if (listenersMap.has(channel)) {
        ipcRenderer.removeListener(channel, listenersMap.get(channel));
        listenersMap.delete(channel);
      }
    }
  }
});
