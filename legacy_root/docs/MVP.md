# Frontend MVP Implementation Plan

Esta pasta contém instruções para agentes implementarem um MVP (Minimum Viable Product) da aplicação de gestão de restaurantes **Boteco Pro** usando React. O foco inicial é utilizar dados locais simulados e oferecer a opção de sincronizar com a API descrita na pasta `Backend`.

## 1. Objetivo do MVP

1. Disponibilizar uma interface web em React para gerenciamento básico de restaurantes.
2. Permitir o funcionamento com dados mockados salvos localmente (por exemplo, em `localStorage`).
3. Implementar opção "Conectar" que sincroniza os dados locais com a API assim que uma URL de backend for configurada.

## 2. Estrutura Inicial Sugerida

- `src/`
  - `components/` – componentes reutilizáveis (botões, formulários etc.).
  - `pages/` – telas principais (Dashboard, Pedidos, Estoque, Mesas, Login/Opcional).
  - `services/` – módulo de acesso aos dados (mock e API real).
  - `hooks/` – hooks customizados (ex.: `useSync` para sincronizar dados).
  - `mocks/` – arquivos JSON simulando as respostas da API.
  - `App.jsx` – ponto de entrada com rotas básicas.

## 3. Funcionalidades do MVP

1. **Listagem de Mesas e Pedidos**
   - Visualizar mesas e status (livre, ocupada).
   - Visualizar pedidos em andamento, utilizando dados de `view_pedidos_em_andamento` (mock).

2. **Visualização de Menu/Pratos**
   - Listar pratos disponíveis usando dados mockados da tabela `Prato`.

3. **Controle de Estoque Simplificado**
   - Visualizar estoque de ingredientes (dados de `view_estoque_ingredientes`).

4. **Sincronização com API**
   - Implementar um serviço de dados que primeiro trabalha apenas com os mocks.
   - Ao clicar em "Conectar" (após inserir a URL da API), o serviço passa a consultar endpoints reais e pode enviar dados armazenados localmente (se aplicável).

5. **Persistência Local**
   - Utilizar `localStorage` ou `IndexedDB` para gravar dados mockados e alterações feitas pelo usuário enquanto não houver conexão.

## 4. Passo a Passo para os Agentes

1. **Configurar Projeto**
   - Criar app React (preferencialmente com `Vite` + `TypeScript` para agilidade).
   - Definir estrutura de pastas conforme a seção 2.

2. **Implementar Camada de Dados**
   - `services/DataService.ts` (ou `.js`): módulo com métodos `getMesas`, `getPedidos`, `getPratos`, etc.
   - Incluir lógica para ler/escrever no `localStorage` quando offline.
   - Adicionar função `syncWithApi(baseUrl)` para sincronizar e atualizar os dados locais.

3. **Criar Componentes Básicos**
   - Tabelas ou cards para mesas, pedidos, estoque e pratos.
   - Botão "Conectar" para configurar a URL e iniciar a sincronização.

4. **Adicionar Roteamento**
   - Utilizar `react-router` para páginas principais (ex.: `/mesas`, `/pedidos`, `/estoque`).

5. **Documentação e Scripts**
   - Incluir scripts de instalação e execução no `package.json` (`dev`, `build`).
   - Explicar como substituir os dados mockados pela API real na documentação (README).

## 5. Referências e Próximos Passos

- A modelagem detalhada e objetos de API estão em `../backend/docs`.
- Assim que o backend estiver disponível, adaptar `DataService` para consumir os endpoints correspondentes às SPs e Views descritas em `05_api_crud.md`.
- Expandir funcionalidades para cadastro e relatórios conforme evoluir o projeto.

