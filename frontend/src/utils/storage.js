/**
 * Storage Utilities - adrisa007/sentinela (ID: 1112237272)
 * 
 * Helpers para localStorage com tratamento de erros
 */

const STORAGE_PREFIX = 'sentinela_'

// Save to localStorage
export const saveToStorage = (key, value) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    const stringValue = typeof value === 'string' ? value : JSON.stringify(value)
    localStorage.setItem(prefixedKey, stringValue)
    console.log(`[Storage] Saved: ${key}`)
    return true
  } catch (error) {
    console.error(`[Storage] Error saving ${key}:`, error)
    return false
  }
}

// Get from localStorage
export const getFromStorage = (key) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    const value = localStorage.getItem(prefixedKey)
    
    if (!value) return null
    
    // Try to parse JSON, fallback to string
    try {
      return JSON.parse(value)
    } catch {
      return value
    }
  } catch (error) {
    console.error(`[Storage] Error reading ${key}:`, error)
    return null
  }
}

// Remove from localStorage
export const removeFromStorage = (key) => {
  try {
    const prefixedKey = STORAGE_PREFIX + key
    localStorage.removeItem(prefixedKey)
    console.log(`[Storage] Removed: ${key}`)
    return true
  } catch (error) {
    console.error(`[Storage] Error removing ${key}:`, error)
    return false
  }
}

// Clear all storage
export const clearStorage = () => {
  try {
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith(STORAGE_PREFIX)) {
        localStorage.removeItem(key)
      }
    })
    console.log('[Storage] All cleared')
    return true
  } catch (error) {
    console.error('[Storage] Error clearing storage:', error)
    return false
  }
}

// Check if token is expired
export const isTokenExpired = (expiryKey = 'token_expiry') => {
  const expiry = getFromStorage(expiryKey)
  if (!expiry) return true
  
  const now = Date.now()
  return now > expiry
}

// Calculate expiry timestamp
export const calculateExpiry = (expiresInMs = 24 * 60 * 60 * 1000) => {
  return Date.now() + expiresInMs
}

export default {
  saveToStorage,
  getFromStorage,
  removeFromStorage,
  clearStorage,
  isTokenExpired,
  calculateExpiry,
}
