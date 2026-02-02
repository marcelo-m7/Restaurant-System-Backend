export interface Mesa {
  mesa_id: number;
  numero: number;
  capacidade: number;
}

export interface Pedido {
  pedido_id: number;
  mesa_id: number;
  funcionario_id: number;
  data_pedido: string;
  status: string;
}

export interface Prato {
  prato_id: number;
  nome_prato: string;
  total_vendas: number;
}

export interface Ingrediente {
  produto_id: number;
  nome_produto: string;
  stock_atual: number;
  stock_minimo: number;
}

export interface Funcionario {
  funcionario_id: number;
  nome_funcionario: string;
  total_horas_normais: number;
  total_horas_extra: number;
}
