# 📦 Schema: `inventory`

O schema `inventory` representa a **gestão de fornecedores** do BotecoPro. Ele serve como fonte de vínculo para os ingredientes utilizados nas receitas, garantindo rastreabilidade e controle de reposição.

---

## 📐 Estrutura

### Tabela

* `supplier`: cadastro de fornecedores (nome, contato, observações)

> Obs: A tabela `core.ingredient` possui uma foreign key para `inventory.supplier`, permitindo conectar cada insumo ao seu fornecedor.

### Funções

Atualmente não há funções (RPC) neste schema.

---

## 🔐 RLS Policies

* Leitura pública (qualquer papel pode consultar fornecedores)
* Escrita restrita a usuários com papel `manager`

---

## 📊 Uso no app

* Exibe dados de fornecedores vinculados a cada ingrediente
* Permite alimentar sistemas de reabastecimento futuro

---

## 🔮 Melhorias futuras

* Histórico de compras por fornecedor
* Integração com pedidos automáticos de reposição
* Campos adicionais: CNPJ, endereço, tipo de insumo fornecido
