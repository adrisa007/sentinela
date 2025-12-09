/**
 * Exemplo de uso do Login.jsx
 * Repository: adrisa007/sentinela (ID: 1112237272)
 */

import { Routes, Route } from 'react-router-dom'
import Login from './Login'

// Exemplo 1: Route básica
function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
    </Routes>
  )
}

// Exemplo 2: Com proteção de rota
function ProtectedApp() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/dashboard"
        element={
          <ProtectedRoute>
            <DashboardPage />
          </ProtectedRoute>
        }
      />
    </Routes>
  )
}

// Exemplo 3: Login programático em outro componente
import { useAuth } from '@contexts/AuthContext'
import { useForm } from 'react-hook-form'

function MyCustomLoginForm() {
  const { login } = useAuth()
  const { register, handleSubmit } = useForm()

  const onSubmit = async (data) => {
    const result = await login({
      username: data.email,
      password: data.password,
    })

    if (result.success) {
      // Sucesso
    } else {
      // Erro
      console.error(result.error)
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('password')} />
      <button type="submit">Login</button>
    </form>
  )
}
