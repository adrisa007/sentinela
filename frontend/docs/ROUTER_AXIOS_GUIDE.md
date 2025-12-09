# React Router + Axios Guide - adrisa007/sentinela (ID: 1112237272)

## 🛣️  React Router

### Rotas Configuradas

| Path | Component | Protected |
|------|-----------|-----------|
| `/` | HomePage | ❌ Public |
| `/login` | LoginPage | ❌ Public |
| `/health` | HealthPage | ❌ Public |
| `/dashboard` | DashboardPage | ✅ Protected |
| `*` | NotFoundPage | ❌ Public |

### Navegação

```jsx
import { Link, useNavigate } from 'react-router-dom'

// Link Component
<Link to="/dashboard">Dashboard</Link>

// Programmatic Navigation
const navigate = useNavigate()
navigate('/dashboard')
navigate(-1) // Voltar
