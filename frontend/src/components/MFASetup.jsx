import { useState } from 'react'
import { useAuth } from '@contexts/AuthContext'

/**
 * MFA Setup Component - adrisa007/sentinela (ID: 1112237272)
 * 
 * Componente para configurar MFA TOTP com QR Code
 */

function MFASetup({ onComplete, onCancel }) {
  const [totpCode, setTotpCode] = useState('')
  const [error, setError] = useState('')
  const [backupCodes, setBackupCodes] = useState([])
  const [step, setStep] = useState('qrcode') // 'qrcode' | 'verify' | 'backup'
  
  const { mfaSetupData, verifyAndEnableMFA, loading } = useAuth()

  const handleVerify = async (e) => {
    e.preventDefault()
    setError('')

    if (totpCode.length !== 6) {
      setError('O código deve ter 6 dígitos')
      return
    }

    const result = await verifyAndEnableMFA(totpCode)

    if (result.success) {
      setBackupCodes(result.backupCodes || [])
      setStep('backup')
    } else {
      setError(result.error)
      setTotpCode('')
    }
  }

  const handleComplete = () => {
    if (onComplete) onComplete()
  }

  // Step 1: QR Code
  if (step === 'qrcode' && mfaSetupData) {
    return (
      <div className="card max-w-lg mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">🔐</div>
            <h2 className="text-2xl font-bold mb-2">Configurar MFA (2FA)</h2>
            <p className="text-gray-600">
              Escaneie o QR Code com seu aplicativo autenticador
            </p>
          </div>

          {/* QR Code */}
          <div className="bg-white p-6 rounded-lg border-2 border-gray-200 flex justify-center">
            {mfaSetupData.qrCode ? (
              <img 
                src={`data:image/png;base64,${mfaSetupData.qrCode}`}
                alt="QR Code MFA"
                className="w-64 h-64"
              />
            ) : (
              <div className="w-64 h-64 flex items-center justify-center bg-gray-100">
                <p className="text-gray-400">Carregando QR Code...</p>
              </div>
            )}
          </div>

          {/* Secret Manual */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600 mb-2">
              Ou digite manualmente:
            </p>
            <code className="block p-2 bg-white border rounded text-center font-mono text-sm break-all">
              {mfaSetupData.secret}
            </code>
          </div>

          {/* Aplicativos Sugeridos */}
          <div className="text-sm text-gray-600">
            <p className="font-semibold mb-2">Aplicativos recomendados:</p>
            <ul className="list-disc list-inside space-y-1">
              <li>Google Authenticator</li>
              <li>Microsoft Authenticator</li>
              <li>Authy</li>
            </ul>
          </div>

          <button
            onClick={() => setStep('verify')}
            className="btn-primary w-full"
          >
            Continuar →
          </button>

          {onCancel && (
            <button
              onClick={onCancel}
              className="btn-ghost w-full"
            >
              Cancelar
            </button>
          )}
        </div>
      </div>
    )
  }

  // Step 2: Verify Code
  if (step === 'verify') {
    return (
      <div className="card max-w-md mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">🔢</div>
            <h2 className="text-2xl font-bold mb-2">Verificar Código</h2>
            <p className="text-gray-600">
              Digite o código de 6 dígitos do seu aplicativo
            </p>
          </div>

          <form onSubmit={handleVerify} className="space-y-4">
            <div>
              <label className="form-label">Código TOTP</label>
              <input
                type="text"
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                maxLength="6"
                className="form-input text-center text-2xl tracking-widest"
                placeholder="000000"
                required
                autoFocus
                disabled={loading}
              />
              {error && (
                <p className="form-error">{error}</p>
              )}
            </div>

            <div className="flex space-x-3">
              <button
                type="button"
                onClick={() => setStep('qrcode')}
                className="btn-ghost flex-1"
                disabled={loading}
              >
                ← Voltar
              </button>
              <button
                type="submit"
                className="btn-primary flex-1"
                disabled={loading || totpCode.length !== 6}
              >
                {loading ? 'Verificando...' : 'Verificar'}
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  // Step 3: Backup Codes
  if (step === 'backup' && backupCodes.length > 0) {
    return (
      <div className="card max-w-md mx-auto">
        <div className="card-body space-y-6">
          <div className="text-center">
            <div className="text-5xl mb-4">✅</div>
            <h2 className="text-2xl font-bold mb-2">MFA Configurado!</h2>
            <p className="text-gray-600">
              Guarde seus códigos de backup em local seguro
            </p>
          </div>

          <div className="bg-warning-50 border-2 border-warning-200 p-4 rounded-lg">
            <p className="text-sm text-warning-800 font-semibold mb-2">
              ⚠️ Importante:
            </p>
            <p className="text-sm text-warning-700">
              Estes códigos podem ser usados se você perder acesso ao seu aplicativo autenticador.
              Cada código só pode ser usado uma vez.
            </p>
          </div>

          <div className="bg-gray-50 p-4 rounded-lg space-y-2">
            {backupCodes.map((code, index) => (
              <div
                key={index}
                className="bg-white p-3 rounded border font-mono text-center"
              >
                {code}
              </div>
            ))}
          </div>

          <button
            onClick={handleComplete}
            className="btn-primary w-full"
          >
            Concluir
          </button>
        </div>
      </div>
    )
  }

  return null
}

export default MFASetup
