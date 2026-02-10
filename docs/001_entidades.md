## V1 — Catálogo de Entidades (responsabilidades primeiro)

### 1) Tenant (Restaurante / Conta SaaS)

* **Responsabilidade:** isolar tudo que pertence a um cliente do SaaS.
* **Guarda/decide:** nome do restaurante, plano, configurações globais (moeda, idioma, etc).
* **Não faz:** não sabe de mesas, pedidos, etc. Só “dono do mundo”.

### 2) Unit (Unidade / Loja) *(mesmo que no V1 seja só 1, já deixa pronto)*

* **Responsabilidade:** representar o local operacional onde as coisas acontecem.
* **Guarda/decide:** nome da unidade, fuso horário, regras locais (ex: taxa serviço habilitada?).
* **Não faz:** não calcula conta, não decide preço de item.

### 3) User (Usuário do sistema)

* **Responsabilidade:** representar quem opera o sistema (garçom, gerente, caixa).
* **Guarda/decide:** identidade, status, permissões/role (se você já quiser no V1).
* **Não faz:** não “é” funcionário RH, nem guarda comissão; é só o ator do sistema.

### 4) Area (Setor do salão)

* **Responsabilidade:** organizar mesas por áreas (salão, varanda, bar).
* **Guarda/decide:** nome, ordem, visibilidade no mapa.
* **Não faz:** não manda pedido, não abre comanda.

### 5) Table (Mesa)

* **Responsabilidade:** recurso físico onde a venda acontece no salão.
* **Guarda/decide:** código/número, capacidade, status operacional (livre/ocupada).
* **Não faz:** não soma valores, não guarda histórico financeiro (isso é da comanda).

### 6) Tab (Comanda / Conta)

* **Responsabilidade:** **agregar consumo** até o fechamento.
* **Guarda/decide:** status (aberta/fechada/cancelada), timestamps, totais (subtotal/taxas/total), referência do “alvo” (mesa).
* **Não faz:** não define preparo/fluxo de cozinha — isso é do pedido.

### 7) Order (Pedido)

* **Responsabilidade:** representar uma “rodada” enviada (criado por um user).
* **Guarda/decide:** status do pedido (rascunho/enviado/cancelado), criado por quem, quando.
* **Não faz:** não calcula totais finais da conta (isso é do Tab).

### 8) OrderItem (Item do pedido)

* **Responsabilidade:** a unidade de venda: “X unidades do produto Y por preço Z”.
* **Guarda/decide:** quantidade, **preço unitário travado**, observação simples.
* **Não faz:** não decide catálogo/variações; só registra a venda.

### 9) Product (Produto)

* **Responsabilidade:** definir o que pode ser vendido.
* **Guarda/decide:** nome, preço base, ativo/inativo.
* **Não faz:** não registra venda (isso é OrderItem), não sabe de mesas.

### 10) Category (Categoria)

* **Responsabilidade:** organizar produtos pra navegação e PDV.
* **Guarda/decide:** nome, ordem.
* **Não faz:** não define preço.

### 11) Payment (Pagamento)

* **Responsabilidade:** registrar liquidação (parcial ou total) de uma comanda.
* **Guarda/decide:** método (dinheiro/cartão/pix), valor, status (pendente/confirmado/estornado).
* **Não faz:** não “fecha” comanda sozinho — ele só registra pagamentos.

---

## Regras de Ouro (pra ficar redondinho e fácil de codar)

* **Preço trava no OrderItem**, nunca no Product na hora de somar (produto pode mudar de preço depois).
* **Tab é o dono do total**, mas ele não “inventa” itens: total vem da soma dos OrderItems + taxas/descontos.
* **Order é fluxo**, Tab é financeiro/agrupador.
* **Mesa não tem dinheiro**, quem tem dinheiro é Tab + Payment.
* **Tenant/Unit são só contexto**, não fazem regra de negócio de venda.

---

## O que ficou fora do V1 (de propósito)

* reservas, fila, ficha técnica/estoque, caixa/turno, promoções, modificadores, delivery…
  Tudo isso entra depois sem quebrar o V1 se a base estiver limpa.

