### `BotecoPro/docs/01_overview.md`

# 01. Visão Geral do Boteco Pro

---

## Objetivo

Este documento apresenta a visão geral do sistema Boteco Pro, seus principais módulos e requisitos funcionais.

### 1. Motivação

Restaurantes enfrentam desafios diários de gerenciamento de:
- Cardápio e preços (avaliar custos de ingredientes e mão de obra).  
- Controle de estoque (ingredientes, bebidas, itens diversos).  
- Relação com fornecedores (encomendas automáticas quando estoque atinge nível mínimo).  
- Funcionários (cálculo de horas trabalhadas, vencimentos e horas-extra).  
- Atendimento a clientes (gerenciamento de mesas, pedidos, sequência de preparo e entrega).  
- Faturamento (emissão de faturas para consumidor final ou empresas, cálculo de IVA).

Boteco Pro busca centralizar todas essas operações em um único banco de dados, permitindo que um aplicativo via API ofereça as funcionalidades necessárias para a operação de um restaurante de porte médio.

---

## 2. Funcionalidades Principais

1. **Cardápio e Itens de Venda**  
   - Cadastro de categorias (Carnes, Peixes, Massas, Bebidas, Sobremesas etc.).  
   - Definição de pratos, bebidas e outros itens com preço de venda calculado ou definido manualmente.  

2. **Compras e Estoque**  
   - Cadastro de produtos (ingredientes, bebidas, insumos diversos) e fornecedores.  
   - Controle de estoque mínimo e estoque de encomenda por produto.  
   - Geração automática de encomenda ao fornecedor quando estoque cai abaixo do mínimo.  

3. **Funcionários e Folha de Pagamento**  
   - Cadastro de funcionários, carreiras (por exemplo: Cozinheiro 2ª Classe, Cozinheiro Chefe, Empregado de Mesa etc.) e salários-base.  
   - Registro diário/mensal de horas trabalhadas (normais e horas-extra).  
   - Cálculo de vencimentos mensais considerando faixa de horas-extra (2h × 1×, próximas 5h × 1.5×, excedentes × 2×).  

4. **Atendimento a Clientes**  
   - Gerenciamento de mesas (número, capacidade, status: livre, ocupada, reservada).  
   - Registro de reservas (opcional).  
   - Fluxo de pedido: inserção de Pedido e PedidoItem → preparo na cozinha → entrega e recolha.  

5. **Faturamento e IVA**  
   - Emissão automática de fatura ao finalizar pedido.  
   - Fatores de IVA: 13% para comida; 23% para bebida.  
   - Suporte a fatura para consumidor final (com ou sem contribuinte) e fatura empresarial (dados completos do cliente).  

6. **Menus Especiais e Promoções**  
   - Cadastro de MenuEspecial para datas comemorativas ou eventos (Dia dos Namorados, Páscoa, Natal).  
   - Cada menu composto por uma sequência fixa de pratos (entrada, prato principal, sobremesa, café) com preço especial.  

---

## 3. Público-Alvo (Usuários)

- **Gerente do Restaurante**: consulta relatórios (faturamento, consumo de estoque, desempenho de pratos), cadastra menus especiais e aprova reservas.  
- **Cozinheiros e Equipe de Cozinha**: visualizam pedidos em andamento e consomem ingredientes (gera movimentação de estoque).  
- **Empregados de Mesa / Garçons**: alocam mesas, registram pedidos, entregam pratos e recolhem faturas.  
- **Equipe Financeira/Contábil**: acompanha faturamento, controle de fornecedores e folha de pagamento.  

---

## 4. Organização do Repositório

- **docs/**: toda a documentação sobre modelagem, diagramas e descrição dos objetos de consulta (Views, Functions, SPs).
- **src/db/sql/**: scripts SQL executáveis, organizados em etapas lógicas (tabelas, objetos de consumo e rotinas de manutenção).
- **README.md**: visão geral do projeto e orientações iniciais.

Com esta estrutura, desenvolvedores e DBAs podem entender rapidamente a arquitetura, modelagem e os objetos de consumo disponíveis pela API.
