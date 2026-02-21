const sharp = require('sharp');
const fs = require('fs').promises;
const path = require('path');

const THUMBNAIL_CONFIG = Object.freeze({
  MAX_SIZE: 800,
  FORMAT: 'jpeg',
  QUALITY: 85
});

/**
 * Generate a thumbnail from source image
 * @param {string} srcPath - Full path to source image
 * @param {string} destPath - Full path to destination thumbnail
 * @param {number} maxSize - Maximum dimension (default: 800)
 * @returns {Promise<{success: boolean, error?: string}>}
 */
async function generateThumbnail(srcPath, destPath, maxSize = THUMBNAIL_CONFIG.MAX_SIZE) {
  try {
    // CRITICAL FIX: Ensure parent directory exists before writing
    // Sharp does NOT create directories automatically
    const destDir = path.dirname(destPath);
    await fs.mkdir(destDir, { recursive: true });

    await sharp(srcPath)
      .resize(maxSize, maxSize, {
        fit: 'inside',
        withoutEnlargement: false
      })
      .jpeg({ quality: THUMBNAIL_CONFIG.QUALITY })
      .toFile(destPath);

    return { success: true };
  } catch (error) {
    console.error('[ThumbnailService] generateThumbnail error:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Check if thumbnail exists
 * @param {string} thumbPath - Full path to thumbnail
 * @returns {Promise<boolean>}
 */
async function thumbnailExists(thumbPath) {
  try {
    await fs.access(thumbPath);
    return true;
  } catch {
    return false;
  }
}

/**
 * Get thumbnail path for given image ID
 * @param {string} thumbsDir - Full path to thumbs directory
 * @param {string} imageId - Image UUID
 * @returns {string}
 */
function getThumbnailPath(thumbsDir, imageId) {
  return path.join(thumbsDir, `${imageId}.jpg`);
}

/**
 * Get thumbs directory path
 * @param {string} projectPath - Full path to project
 * @returns {string}
 */
function getThumbsDir(projectPath) {
  return path.join(projectPath, THUMBNAIL_CONFIG.DIR_NAME);
}

/**
 * Ensure thumbs directory exists
 * @param {string} projectPath - Full path to project
 * @returns {Promise<{success: boolean, thumbsDir?: string, error?: string}>}
 */
async function ensureThumbsDir(projectPath) {
  try {
    const thumbsDir = getThumbsDir(projectPath);
    await fs.mkdir(thumbsDir, { recursive: true });
    return { success: true, thumbsDir };
  } catch (error) {
    console.error('[ThumbnailService] ensureThumbsDir error:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Delete thumbnail file
 * @param {string} thumbPath - Full path to thumbnail
 * @returns {Promise<{success: boolean, error?: string}>}
 */
async function deleteThumbnail(thumbPath) {
  try {
    await fs.unlink(thumbPath);
    return { success: true };
  } catch (error) {
    if (error.code === 'ENOENT') {
      return { success: true };
    }
    console.error('[ThumbnailService] deleteThumbnail error:', error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Generate thumbnail if it doesn't exist
 * @param {string} srcPath - Full path to source image
 * @param {string} thumbsDir - Full path to thumbs directory
 * @param {string} imageId - Image UUID
 * @returns {Promise<{success: boolean, thumbPath?: string, error?: string}>}
 */
async function ensureThumbnail(srcPath, thumbsDir, imageId) {
  try {
    // CRITICAL FIX: Ensure thumbs directory exists before generating thumbnail
    // This prevents race conditions and provides defense in depth
    await fs.mkdir(thumbsDir, { recursive: true });

    const thumbPath = getThumbnailPath(thumbsDir, imageId);
    const exists = await thumbnailExists(thumbPath);

    if (exists) {
      return { success: true, thumbPath };
    }

    const result = await generateThumbnail(srcPath, thumbPath);
    if (!result.success) {
      return result;
    }

    return { success: true, thumbPath };
  } catch (error) {
    console.error('[ThumbnailService] ensureThumbnail error:', error.message);
    return { success: false, error: error.message };
  }
}

module.exports = {
  generateThumbnail,
  thumbnailExists,
  getThumbnailPath,
  getThumbsDir,
  ensureThumbsDir,
  deleteThumbnail,
  ensureThumbnail,
  THUMBNAIL_CONFIG
};
