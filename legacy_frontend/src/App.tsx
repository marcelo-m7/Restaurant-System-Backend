import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import MesasPage from './pages/MesasPage';
import PedidosPage from './pages/PedidosPage';
import PratosPage from './pages/PratosPage';
import EstoquePage from './pages/EstoquePage';
import ConnectPage from './pages/ConnectPage';
import GestaoPage from './pages/GestaoPage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/mesas" />} />
        <Route path="/connect" element={<ConnectPage />} />
        <Route path="/mesas" element={<MesasPage />} />
        <Route path="/pedidos" element={<PedidosPage />} />
        <Route path="/pratos" element={<PratosPage />} />
        <Route path="/estoque" element={<EstoquePage />} />
        <Route path="/gestao" element={<GestaoPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
