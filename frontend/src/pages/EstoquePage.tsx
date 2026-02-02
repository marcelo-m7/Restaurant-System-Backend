import React, { useEffect, useState } from 'react';
import { DataService } from '../services/DataService';
import type { Ingrediente } from '../types';

export default function EstoquePage() {
  const [itens, setItens] = useState<Ingrediente[]>([]);

  useEffect(() => {
    DataService.getEstoque().then(setItens);
  }, []);

  return (
    <div>
      <h1>Estoque de Ingredientes</h1>
      <table>
        <thead>
          <tr>
            <th>Produto</th>
            <th>Stock Atual</th>
            <th>Stock Mínimo</th>
          </tr>
        </thead>
        <tbody>
          {itens.map(i => (
            <tr key={i.produto_id}>
              <td>{i.nome_produto}</td>
              <td>{i.stock_atual}</td>
              <td>{i.stock_minimo}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
