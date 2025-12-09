import { Routes, Route } from 'react-router-dom'
import Layout from '@components/Layout'
import HomePage from '@pages/HomePage'
import DashboardPage from '@pages/DashboardPage'
import HealthPage from '@pages/HealthPage'
import NotFoundPage from '@pages/NotFoundPage'

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/health" element={<HealthPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </Layout>
  )
}

export default App
