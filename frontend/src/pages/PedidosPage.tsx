import React, { useEffect, useState } from 'react';
import { DataService } from '../services/DataService';
import type { Pedido } from '../types';

export default function PedidosPage() {
  const [pedidos, setPedidos] = useState<Pedido[]>([]);

  useEffect(() => {
    DataService.getPedidos().then(setPedidos);
  }, []);

  return (
    <div>
      <h1>Pedidos em Andamento</h1>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Mesa</th>
            <th>Funcionário</th>
            <th>Data</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {pedidos.map(p => (
            <tr key={p.pedido_id}>
              <td>{p.pedido_id}</td>
              <td>{p.mesa_id}</td>
              <td>{p.funcionario_id}</td>
              <td>{new Date(p.data_pedido).toLocaleString()}</td>
              <td>{p.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
