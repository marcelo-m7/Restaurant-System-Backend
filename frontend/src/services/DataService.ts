import type { Mesa, Pedido, Prato, Ingrediente, Funcionario } from '../types';
import { ApiService } from './ApiService';

const LOCAL_STORAGE_KEY = 'botecoProData';
let useApi = false;

function loadMocks<T>(fileName: string): Promise<T[]> {
  return fetch(`/src/mocks/${fileName}`).then(res => res.json());
}

export async function getMesas(): Promise<Mesa[]> {
  if (!useApi) {
    return loadMocks<Mesa>('mesas.json');
  }
  return ApiService.get<Mesa[]>('/mesas/disponiveis');
}

export async function getPedidos(): Promise<Pedido[]> {
  if (!useApi) {
    return loadMocks<Pedido>('pedidos.json');
  }
  return ApiService.get<Pedido[]>('/pedidos/em/andamento');
}

export async function getPratos(): Promise<Prato[]> {
  if (!useApi) {
    return loadMocks<Prato>('pratos.json');
  }
  return ApiService.get<Prato[]>('/pratos/populares');
}

export async function getEstoque(): Promise<Ingrediente[]> {
  if (!useApi) {
    return loadMocks<Ingrediente>('estoque.json');
  }
  return ApiService.get<Ingrediente[]>('/estoque/ingredientes');
}

export async function getFuncionarios(): Promise<Funcionario[]> {
  if (!useApi) {
    return loadMocks<Funcionario>('funcionarios.json');
  }
  return ApiService.get<Funcionario[]>('/horas/funcionario');
}

export function saveLocal<T>(key: string, data: T[]): void {
  localStorage.setItem(`${LOCAL_STORAGE_KEY}-${key}`, JSON.stringify(data));
}

export function loadLocal<T>(key: string): T[] | null {
  const raw = localStorage.getItem(`${LOCAL_STORAGE_KEY}-${key}`);
  return raw ? JSON.parse(raw) : null;
}

export async function syncWithApi(baseUrl: string): Promise<void> {
  useApi = true;
  ApiService.setBaseUrl(baseUrl);
  // Stub: could send local changes to API here
}

export const DataService = {
  getMesas,
  getPedidos,
  getPratos,
  getEstoque,
  getFuncionarios,
  saveLocal,
  loadLocal,
  syncWithApi
};
