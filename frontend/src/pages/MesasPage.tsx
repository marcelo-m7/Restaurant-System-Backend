import React, { useEffect, useState } from 'react';
import { DataService } from '../services/DataService';
import type { Mesa } from '../types';

export default function MesasPage() {
  const [mesas, setMesas] = useState<Mesa[]>([]);

  useEffect(() => {
    DataService.getMesas().then(setMesas);
  }, []);

  return (
    <div>
      <h1>Mesas</h1>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Capacidade</th>
          </tr>
        </thead>
        <tbody>
          {mesas.map(mesa => (
            <tr key={mesa.mesa_id}>
              <td>{mesa.numero}</td>
              <td>{mesa.capacidade}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
