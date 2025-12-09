# Dashboard Gestor - adrisa007/sentinela (ID: 1112237272)

## 📊 Features

### Gráficos (Chart.js)
- ✅ **Gráfico de Barras** - % Execução de Contratos
- ✅ **Gráfico Doughnut** - Distribuição de Riscos
- ✅ **Dados Dinâmicos** - Atualização via API

### Métricas
- ✅ Total de Contratos
- ✅ Contratos Ativos
- ✅ Valor Total (R$)
- ✅ Execução Média (%)

### Lista de Contratos
- ✅ Tabela completa com todos os contratos
- ✅ Barra de progresso visual
- ✅ Valores formatados (R$)
- ✅ Status coloridos

### Alertas de Certidões
- ✅ Certidões vencendo
- ✅ Certidões vencidas
- ✅ Prioridade visual (Crítica, Alta, Média)

## 🔌 Integração API

### Endpoints Esperados

```javascript
// Buscar contratos
GET /contratos
Response: [
  {
    id: 1,
    numero: "CONT-2024-001",
    descricao: "Serviços de Vigilância",
    valor: 150000,
    percentual_execucao: 75,
    status: "ATIVO",
    fornecedor: "Empresa XYZ"
  }
]

// Buscar alertas de certidões
GET /contratos/alertas/certidoes
Response: [
  {
    id: 1,
    tipo: "CERTIDAO_VENCENDO",
    contrato_numero: "CONT-2024-001",
    mensagem: "Certidão vence em 15 dias",
    dias_restantes: 15,
    prioridade: "ALTA"
  }
]
