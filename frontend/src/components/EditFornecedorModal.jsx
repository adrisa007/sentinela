import { useState, useEffect } from 'react'
import { formatCNPJorCPF, isValidCNPJorCPF, unformatCNPJ } from '@utils/cnpjUtils'

/**
 * Modal para Editar Fornecedor - adrisa007/sentinela (ID: 1112237272)
 */

function EditFornecedorModal({ isOpen, onClose, onSave, fornecedor }) {
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    cnpj: '',
    razao_social: '',
    nome_fantasia: '',
    tipo: 'JURIDICA',
    municipio: '',
    uf: '',
    telefone: '',
    email: '',
  })
  const [errors, setErrors] = useState({})

  // Preencher form quando fornecedor mudar
  useEffect(() => {
    if (fornecedor && isOpen) {
      setFormData({
        cnpj: formatCNPJorCPF(fornecedor.cnpj),
        razao_social: fornecedor.razao_social || '',
        nome_fantasia: fornecedor.nome_fantasia || '',
        tipo: fornecedor.tipo || 'JURIDICA',
        municipio: fornecedor.municipio || '',
        uf: fornecedor.uf || '',
        telefone: fornecedor.telefone || '',
        email: fornecedor.email || '',
      })
    }
  }, [fornecedor, isOpen])

  const handleChange = (field, value) => {
    if (field === 'cnpj') {
      value = formatCNPJorCPF(value)
    }
    setFormData(prev => ({ ...prev, [field]: value }))
    // Limpar erro do campo
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: null }))
    }
  }

  const validate = () => {
    const newErrors = {}

    if (!formData.cnpj) {
      newErrors.cnpj = 'CNPJ/CPF é obrigatório'
    } else if (!isValidCNPJorCPF(formData.cnpj)) {
      newErrors.cnpj = 'CNPJ/CPF inválido'
    }

    if (!formData.razao_social) {
      newErrors.razao_social = 'Razão Social é obrigatória'
    }

    if (!formData.email) {
      newErrors.email = 'Email é obrigatório'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Email inválido'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!validate()) {
      return
    }

    setLoading(true)
    try {
      await new Promise(resolve => setTimeout(resolve, 1000)) // Simular API
      const updatedFornecedor = {
        ...fornecedor,
        ...formData,
        cnpj: unformatCNPJ(formData.cnpj),
      }
      onSave(updatedFornecedor)
      handleClose()
    } catch (error) {
      alert('Erro ao atualizar fornecedor: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleClose = () => {
    setFormData({
      cnpj: '',
      razao_social: '',
      nome_fantasia: '',
      tipo: 'JURIDICA',
      municipio: '',
      uf: '',
      telefone: '',
      email: '',
    })
    setErrors({})
    onClose()
  }

  if (!isOpen || !fornecedor) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-2xl max-w-3xl w-full max-h-[95vh] overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold flex items-center gap-3">
                ✏️ Editar Fornecedor
              </h2>
              <p className="text-blue-100 text-sm mt-1">
                Atualize os dados cadastrais do fornecedor
              </p>
            </div>
            <button
              onClick={handleClose}
              className="text-white hover:bg-white hover:bg-opacity-20 rounded-full p-2 transition-colors"
              title="Fechar"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="flex flex-col h-[calc(95vh-140px)]">
          <div className="p-6 overflow-y-auto flex-1">
            <div className="space-y-6">
              {/* CNPJ/CPF e Tipo - Linha 1 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    CNPJ/CPF <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={formData.cnpj}
                    onChange={(e) => handleChange('cnpj', e.target.value)}
                    placeholder="00.000.000/0000-00"
                    className={`w-full px-4 py-2.5 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all ${
                      errors.cnpj ? 'border-red-300 bg-red-50' : 'border-gray-300'
                    }`}
                    maxLength={18}
                  />
                  {errors.cnpj && (
                    <p className="text-red-600 text-sm mt-1 flex items-center gap-1">
                      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                      </svg>
                      {errors.cnpj}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Tipo de Pessoa
                  </label>
                  <select
                    value={formData.tipo}
                    onChange={(e) => handleChange('tipo', e.target.value)}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  >
                    <option value="JURIDICA">🏛️ Pessoa Jurídica</option>
                    <option value="FISICA">👤 Pessoa Física</option>
                  </select>
                </div>
              </div>

              {/* Razão Social e Nome Fantasia - Linha 2 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Razão Social / Nome Completo <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={formData.razao_social}
                    onChange={(e) => handleChange('razao_social', e.target.value)}
                    placeholder="Nome completo ou razão social"
                    className={`w-full px-4 py-2.5 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all ${
                      errors.razao_social ? 'border-red-300 bg-red-50' : 'border-gray-300'
                    }`}
                  />
                  {errors.razao_social && (
                    <p className="text-red-600 text-sm mt-1 flex items-center gap-1">
                      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                      </svg>
                      {errors.razao_social}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Nome Fantasia
                  </label>
                  <input
                    type="text"
                    value={formData.nome_fantasia}
                    onChange={(e) => handleChange('nome_fantasia', e.target.value)}
                    placeholder="Nome fantasia (opcional)"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  />
                </div>
              </div>

              {/* Email e Telefone - Linha 3 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Email <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    placeholder="email@exemplo.com"
                    className={`w-full px-4 py-2.5 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all ${
                      errors.email ? 'border-red-300 bg-red-50' : 'border-gray-300'
                    }`}
                  />
                  {errors.email && (
                    <p className="text-red-600 text-sm mt-1 flex items-center gap-1">
                      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                      </svg>
                      {errors.email}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Telefone
                  </label>
                  <input
                    type="tel"
                    value={formData.telefone}
                    onChange={(e) => handleChange('telefone', e.target.value)}
                    placeholder="(00) 00000-0000"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  />
                </div>
              </div>

              {/* Município e UF - Linha 4 */}
              <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                <div className="md:col-span-4">
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Município
                  </label>
                  <input
                    type="text"
                    value={formData.municipio}
                    onChange={(e) => handleChange('municipio', e.target.value)}
                    placeholder="Nome da cidade"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
                  />
                </div>
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    UF
                  </label>
                  <input
                    type="text"
                    value={formData.uf}
                    onChange={(e) => handleChange('uf', e.target.value.toUpperCase())}
                    placeholder="SP"
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-center font-semibold"
                    maxLength={2}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="border-t border-gray-200 bg-gray-50 px-6 py-4">
            <div className="flex justify-end gap-3">
              <button
                type="button"
                onClick={handleClose}
                disabled={loading}
                className="px-6 py-2.5 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-100 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-6 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                {loading ? (
                  <>
                    <svg className="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Atualizando...
                  </>
                ) : (
                  <>
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Salvar Alterações
                  </>
                )}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  )
}

export default EditFornecedorModal
