# 🪑 Schema: `client`

O schema `client` representa as entidades relacionadas à **gestão de clientes e mesas** do BotecoPro.

É utilizado tanto para registrar dados cadastrais de clientes quanto para controlar a disponibilidade das mesas no ambiente físico do bar ou restaurante.

---

## 📐 Estrutura

### Tabelas

* `client`: cadastro de clientes (nome, endereço, tipo de cliente)
* `table_seating`: controle das mesas físicas do local (número, lugares, status de disponibilidade)

### Funções

Este schema não possui funções diretas (RPC), mas é utilizado como referência em outros domínios como `order`.

---

## 🔐 RLS Policies

* Leitura: liberada para todos
* Escrita e alteração: restrita a usuários com papel `manager`

---

## 📊 Uso no app

* Permite exibir lista de mesas disponíveis para seleção
* Associar pedidos a clientes cadastrados ou anônimos

---

## 🔮 Melhorias futuras

* Múltiplas zonas/ambientes (salão, varanda, externo)
* Controle de ocupação em tempo real
* Histórico de clientes e preferências
