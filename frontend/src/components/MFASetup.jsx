import { useState, useEffect } from 'react'
import { useAuth } from '@contexts/AuthContext'

function MFASetup({ onComplete }) {
  const [totpCode, setTotpCode] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [backupCodes, setBackupCodes] = useState([])
  
  const { setupMFA, verifyAndEnableMFA, mfaSetupData, user } = useAuth()

  useEffect(() => {
    if (!mfaSetupData) {
      handleSetupMFA()
    }
  }, [])

  const handleSetupMFA = async () => {
    setLoading(true)
    const result = await setupMFA()
    setLoading(false)
    
    if (!result.success) {
      setError(result.error)
    }
  }

  const handleVerify = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    const result = await verifyAndEnableMFA(totpCode)
    setLoading(false)

    if (result.success) {
      setBackupCodes(result.backupCodes || [])
      if (onComplete) onComplete()
    } else {
      setError(result.error)
    }
  }

  if (backupCodes.length > 0) {
    return (
      <div className="card max-w-md mx-auto">
        <h2 className="text-2xl font-bold mb-4">✅ MFA Configurado!</h2>
        <p className="mb-4">Guarde estes códigos de backup em local seguro:</p>
        <div className="bg-gray-100 p-4 rounded-lg space-y-2">
          {backupCodes.map((code, i) => (
            <div key={i} className="font-mono">{code}</div>
          ))}
        </div>
        <button onClick={onComplete} className="btn-primary w-full mt-4">
          Continuar
        </button>
      </div>
    )
  }

  return (
    <div className="card max-w-md mx-auto">
      <div className="text-center mb-6">
        <div className="text-5xl mb-4">🔐</div>
        <h2 className="text-2xl font-bold mb-2">Configurar MFA</h2>
        <p className="text-gray-600">
          MFA é obrigatório para usuários {user?.role}
        </p>
      </div>

      {mfaSetupData ? (
        <>
          <div className="mb-6">
            <p className="text-sm text-gray-600 mb-4">
              Escaneie o QR Code com seu aplicativo autenticador:
            </p>
            <div className="bg-white p-4 rounded-lg border-2 border-gray-200">
              <img 
                src={`data:image/png;base64,${mfaSetupData.qrCode}`} 
                alt="QR Code MFA"
                className="mx-auto"
              />
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Secret: <code className="bg-gray-100 px-2 py-1 rounded">{mfaSetupData.secret}</code>
            </p>
          </div>

          <form onSubmit={handleVerify}>
            <label className="block text-sm font-medium mb-2">
              Digite o código de 6 dígitos:
            </label>
            <input
              type="text"
              value={totpCode}
              onChange={(e) => setTotpCode(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg mb-4"
              placeholder="000000"
              maxLength="6"
              required
            />

            {error && (
              <div className="p-3 bg-red-50 text-red-600 rounded-lg text-sm mb-4">
                {error}
              </div>
            )}

            <button type="submit" className="btn-primary w-full" disabled={loading}>
              {loading ? 'Verificando...' : 'Verificar e Ativar MFA'}
            </button>
          </form>
        </>
      ) : (
        <div className="text-center py-8">
          <div className="spinner w-12 h-12 mx-auto mb-4"></div>
          <p>Gerando QR Code...</p>
        </div>
      )}
    </div>
  )
}

export default MFASetup
