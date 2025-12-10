/**
 * Utilitários de CNPJ/CPF - adrisa007/sentinela (ID: 1112237272)
 */

/**
 * Formata CNPJ: 12345678000190 -> 12.345.678/0001-90
 */
export const formatCNPJ = (value) => {
  if (!value) return ''
  
  // Remove tudo que não é dígito
  const numbers = value.replace(/\D/g, '')
  
  // CNPJ (14 dígitos)
  if (numbers.length <= 14) {
    return numbers
      .replace(/^(\d{2})(\d)/, '$1.$2')
      .replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3')
      .replace(/\.(\d{3})(\d)/, '.$1/$2')
      .replace(/(\d{4})(\d)/, '$1-$2')
  }
  
  return numbers.slice(0, 14)
}

/**
 * Formata CPF: 12345678901 -> 123.456.789-01
 */
export const formatCPF = (value) => {
  if (!value) return ''
  
  const numbers = value.replace(/\D/g, '')
  
  // CPF (11 dígitos)
  if (numbers.length <= 11) {
    return numbers
      .replace(/^(\d{3})(\d)/, '$1.$2')
      .replace(/^(\d{3})\.(\d{3})(\d)/, '$1.$2.$3')
      .replace(/\.(\d{3})(\d)/, '.$1-$2')
  }
  
  return numbers.slice(0, 11)
}

/**
 * Remove formatação do CNPJ/CPF
 */
export const unformatCNPJ = (value) => {
  return value ? value.replace(/\D/g, '') : ''
}

/**
 * Valida CNPJ
 */
export const isValidCNPJ = (cnpj) => {
  const numbers = unformatCNPJ(cnpj)
  
  if (numbers.length !== 14) return false
  
  // Elimina CNPJs invalidos conhecidos
  if (/^(\d)\1+$/.test(numbers)) return false
  
  // Valida DVs
  let tamanho = numbers.length - 2
  let numeros = numbers.substring(0, tamanho)
  const digitos = numbers.substring(tamanho)
  let soma = 0
  let pos = tamanho - 7
  
  for (let i = tamanho; i >= 1; i--) {
    soma += numeros.charAt(tamanho - i) * pos--
    if (pos < 2) pos = 9
  }
  
  let resultado = soma % 11 < 2 ? 0 : 11 - soma % 11
  if (resultado != digitos.charAt(0)) return false
  
  tamanho = tamanho + 1
  numeros = numbers.substring(0, tamanho)
  soma = 0
  pos = tamanho - 7
  
  for (let i = tamanho; i >= 1; i--) {
    soma += numeros.charAt(tamanho - i) * pos--
    if (pos < 2) pos = 9
  }
  
  resultado = soma % 11 < 2 ? 0 : 11 - soma % 11
  if (resultado != digitos.charAt(1)) return false
  
  return true
}

/**
 * Valida CPF
 */
export const isValidCPF = (cpf) => {
  const numbers = unformatCPF(cpf)
  
  if (numbers.length !== 11) return false
  
  // Elimina CPFs invalidos conhecidos
  if (/^(\d)\1+$/.test(numbers)) return false
  
  // Valida 1o digito
  let add = 0
  for (let i = 0; i < 9; i++) {
    add += parseInt(numbers.charAt(i)) * (10 - i)
  }
  let rev = 11 - (add % 11)
  if (rev === 10 || rev === 11) rev = 0
  if (rev !== parseInt(numbers.charAt(9))) return false
  
  // Valida 2o digito
  add = 0
  for (let i = 0; i < 10; i++) {
    add += parseInt(numbers.charAt(i)) * (11 - i)
  }
  rev = 11 - (add % 11)
  if (rev === 10 || rev === 11) rev = 0
  if (rev !== parseInt(numbers.charAt(10))) return false
  
  return true
}

/**
 * Detecta se é CNPJ ou CPF e formata
 */
export const formatCNPJorCPF = (value) => {
  const numbers = unformatCNPJ(value)
  
  if (numbers.length <= 11) {
    return formatCPF(value)
  } else {
    return formatCNPJ(value)
  }
}

/**
 * Valida CNPJ ou CPF
 */
export const isValidCNPJorCPF = (value) => {
  const numbers = unformatCNPJ(value)
  
  if (numbers.length === 11) {
    return isValidCPF(value)
  } else if (numbers.length === 14) {
    return isValidCNPJ(value)
  }
  
  return false
}

export default {
  formatCNPJ,
  formatCPF,
  formatCNPJorCPF,
  unformatCNPJ,
  isValidCNPJ,
  isValidCPF,
  isValidCNPJorCPF,
}
