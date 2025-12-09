# Pages - adrisa007/sentinela (ID: 1112237272)

Páginas da aplicação React.

## 📄 Páginas Disponíveis

### HomePage (`/`)
Página inicial com apresentação do sistema.

**Features:**
- Hero section
- Stats cards
- Features grid
- CTA dinâmico (login ou dashboard)

### LoginPage (`/login`)
Página de autenticação.

**Features:**
- Login com usuário/senha
- Campo MFA condicional
- Validação de formulário
- Error handling
- Auto-redirect se autenticado

### DashboardPage (`/dashboard`)
Dashboard principal do sistema.

**Features:**
- Métricas em cards
- Alerta de MFA obrigatório
- Quick actions
- Informações do usuário

### HealthPage (`/health`)
Verificação de status do sistema.

**Features:**
- Health check do backend
- Status cards (API, DB, Service)
- JSON detalhado
- Botão atualizar

### NotFoundPage (`*`)
Página 404.

**Features:**
- Design amigável
- Link para home
- Animações

## 🎯 Uso

### Importação Individual
```jsx
import HomePage from '@pages/HomePage'
