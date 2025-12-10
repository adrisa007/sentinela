import { useState } from 'react'
import { formatCNPJorCPF, isValidCNPJorCPF, unformatCNPJ } from '@utils/cnpjUtils'

/**
 * Modal para Adicionar Fornecedor - adrisa007/sentinela (ID: 1112237272)
 */

function AddFornecedorModal({ isOpen, onClose, onSave }) {
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
    
    if (!validate()) return

    setLoading(true)
    try {
      await new Promise(resolve => setTimeout(resolve, 1000)) // Simular API
      onSave({
        ...formData,
        cnpj: unformatCNPJ(formData.cnpj),
        status: 'ATIVO',
        contratos_ativos: 0,
        valor_total: 0,
      })
      handleClose()
    } catch (error) {
      alert('Erro ao salvar fornecedor: ' + error.message)
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

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-primary-600 text-white p-6">
          <h2 className="text-2xl font-bold">➕ Adicionar Fornecedor</h2>
          <p className="text-primary-100 text-sm mt-1">
            Preencha os dados do novo fornecedor
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 overflow-y-auto max-h-[calc(90vh-180px)]">
          <div className="space-y-5">
            {/* CNPJ/CPF */}
            <div>
              <label className="form-label">
                CNPJ/CPF <span className="text-danger-500">*</span>
              </label>
              <input
                type="text"
                value={formData.cnpj}
                onChange={(e) => handleChange('cnpj', e.target.value)}
                placeholder="00.000.000/0000-00"
                className={`form-input ${errors.cnpj ? 'border-danger-300' : ''}`}
                maxLength={18}
              />
              {errors.cnpj && (
                <p className="text-danger-600 text-sm mt-1">{errors.cnpj}</p>
              )}
            </div>

            {/* Tipo */}
            <div>
              <label className="form-label">Tipo</label>
              <select
                value={formData.tipo}
                onChange={(e) => handleChange('tipo', e.target.value)}
                className="form-input"
              >
                <option value="JURIDICA">🏛️ Pessoa Jurídica</option>
                <option value="FISICA">👤 Pessoa Física</option>
              </select>
            </div>

            {/* Razão Social */}
            <div>
              <label className="form-label">
                Razão Social <span className="text-danger-500">*</span>
              </label>
              <input
                type="text"
                value={formData.razao_social}
                onChange={(e) => handleChange('razao_social', e.target.value)}
                placeholder="Nome completo ou razão social"
                className={`form-input ${errors.razao_social ? 'border-danger-300' : ''}`}
              />
              {errors.razao_social && (
                <p className="text-danger-600 text-sm mt-1">{errors.razao_social}</p>
              )}
            </div>

            {/* Nome Fantasia */}
            <div>
              <label className="form-label">Nome Fantasia</label>
              <input
                type="text"
                value={formData.nome_fantasia}
                onChange={(e) => handleChange('nome_fantasia', e.target.value)}
                placeholder="Nome fantasia (opcional)"
                className="form-input"
              />
            </div>

            {/* Município/UF */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="md:col-span-3">
                <label className="form-label">Município</label>
                <input
                  type="text"
                  value={formData.municipio}
                  onChange={(e) => handleChange('municipio', e.target.value)}
                  placeholder="Cidade"
                  className="form-input"
                />
              </div>
              <div>
                <label className="form-label">UF</label>
                <input
                  type="text"
                  value={formData.uf}
                  onChange={(e) => handleChange('uf', e.target.value.toUpperCase())}
                  placeholder="SP"
                  className="form-input"
                  maxLength={2}
                />
              </div>
            </div>

            {/* Telefone */}
            <div>
              <label className="form-label">Telefone</label>
              <input
                type="tel"
                value={formData.telefone}
                onChange={(e) => handleChange('telefone', e.target.value)}
                placeholder="(00) 0000-0000"
                className="form-input"
              />
            </div>

            {/* Email */}
            <div>
              <label className="form-label">
                Email <span className="text-danger-500">*</span>
              </label>
              <input
                type="email"
                value={formData.email}
                onChange={(e) => handleChange('email', e.target.value)}
                placeholder="email@exemplo.com"
                className={`form-input ${errors.email ? 'border-danger-300' : ''}`}
              />
              {errors.email && (
                <p className="text-danger-600 text-sm mt-1">{errors.email}</p>
              )}
            </div>
          </div>
        </form>

        {/* Footer */}
        <div className="border-t border-gray-200 bg-gray-50 px-6 py-4">
          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={handleClose}
              disabled={loading}
              className="btn-ghost"
            >
              Cancelar
            </button>
            <button
              onClick={handleSubmit}
              disabled={loading}
              className="btn-primary disabled:opacity-50"
            >
              {loading ? '⏳ Salvando...' : '✅ Salvar Fornecedor'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default AddFornecedorModal
