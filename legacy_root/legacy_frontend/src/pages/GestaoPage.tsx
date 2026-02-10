import React, { useEffect, useState } from 'react';
import { DataService } from '../services/DataService';
import type { Funcionario } from '../types';

export default function GestaoPage() {
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([]);

  useEffect(() => {
    DataService.getFuncionarios().then(setFuncionarios);
  }, []);

  return (
    <div>
      <h1>Horas por Funcionário</h1>
      <table>
        <thead>
          <tr>
            <th>Nome</th>
            <th>Horas Normais</th>
            <th>Horas Extra</th>
          </tr>
        </thead>
        <tbody>
          {funcionarios.map(f => (
            <tr key={f.funcionario_id}>
              <td>{f.nome_funcionario}</td>
              <td>{f.total_horas_normais}</td>
              <td>{f.total_horas_extra}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
