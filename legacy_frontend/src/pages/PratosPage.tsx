import React, { useEffect, useState } from 'react';
import { DataService } from '../services/DataService';
import type { Prato } from '../types';

export default function PratosPage() {
  const [pratos, setPratos] = useState<Prato[]>([]);

  useEffect(() => {
    DataService.getPratos().then(setPratos);
  }, []);

  return (
    <div>
      <h1>Pratos Populares</h1>
      <table>
        <thead>
          <tr>
            <th>Prato</th>
            <th>Total Vendas</th>
          </tr>
        </thead>
        <tbody>
          {pratos.map(p => (
            <tr key={p.prato_id}>
              <td>{p.nome_prato}</td>
              <td>{p.total_vendas}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
