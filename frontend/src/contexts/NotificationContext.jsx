import { createContext, useContext, useState, useCallback } from 'react'

/**
 * NotificationContext - adrisa007/sentinela (ID: 1112237272)
 * 
 * Sistema de notificações toast
 */

const NotificationContext = createContext(null)

export const useNotification = () => {
  const context = useContext(NotificationContext)
  if (!context) {
    throw new Error('useNotification must be used within NotificationProvider')
  }
  return context
}

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([])

  const addNotification = useCallback((message, type = 'info', duration = 3000) => {
    const id = Date.now()
    const notification = { id, message, type, duration }
    
    setNotifications((prev) => [...prev, notification])
    
    // Auto-remover após duração
    if (duration > 0) {
      setTimeout(() => {
        removeNotification(id)
      }, duration)
    }
    
    return id
  }, [])

  const removeNotification = useCallback((id) => {
    setNotifications((prev) => prev.filter((notif) => notif.id !== id))
  }, [])

  // Helpers
  const success = useCallback((message, duration) => {
    return addNotification(message, 'success', duration)
  }, [addNotification])

  const error = useCallback((message, duration) => {
    return addNotification(message, 'error', duration)
  }, [addNotification])

  const warning = useCallback((message, duration) => {
    return addNotification(message, 'warning', duration)
  }, [addNotification])

  const info = useCallback((message, duration) => {
    return addNotification(message, 'info', duration)
  }, [addNotification])

  const value = {
    notifications,
    addNotification,
    removeNotification,
    success,
    error,
    warning,
    info,
  }

  return (
    <NotificationContext.Provider value={value}>
      {children}
      <NotificationContainer />
    </NotificationContext.Provider>
  )
}

// Componente de notificações
function NotificationContainer() {
  const { notifications, removeNotification } = useNotification()

  const getTypeStyles = (type) => {
    switch (type) {
      case 'success':
        return 'bg-success-50 border-success-500 text-success-800'
      case 'error':
        return 'bg-danger-50 border-danger-500 text-danger-800'
      case 'warning':
        return 'bg-warning-50 border-warning-500 text-warning-800'
      default:
        return 'bg-info-50 border-info-500 text-info-800'
    }
  }

  if (notifications.length === 0) return null

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2">
      {notifications.map((notif) => (
        <div
          key={notif.id}
          className={`p-4 border-l-4 rounded-lg shadow-lg animate-slide-in ${getTypeStyles(notif.type)}`}
        >
          <div className="flex items-center justify-between">
            <p className="font-medium">{notif.message}</p>
            <button
              onClick={() => removeNotification(notif.id)}
              className="ml-4 text-lg hover:opacity-70"
            >
              ×
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}

export default NotificationContext
