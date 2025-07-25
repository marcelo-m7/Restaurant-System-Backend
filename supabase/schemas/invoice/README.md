# 🧾 Schema: `invoice`

O schema `invoice` é responsável por armazenar os dados de faturamento dos pedidos do BotecoPro. Ele consolida os valores de itens e adicionais, aplica impostos e registra a fatura final.

---

## 📐 Estrutura

### Tabela

* `invoice`: contém uma linha por pedido finalizado, com valores totais, impostos e data da emissão.

### Funções (RPC)

* `generate_invoice(order_id, food_tax_rate, drink_tax_rate)`

Calcula o valor total do pedido com base nos itens, adicionais e categorias (comida/bebida), e insere a fatura na tabela.

---

## 🔐 RLS Policies

* **Leitura:** permitida para gerentes ou para o funcionário autor do pedido.
* **Escrita:** apenas `manager` pode gerar uma nova fatura (via RPC).

---

## 📊 Exemplo de uso

1. Após confirmar o pedido, app chama `invoice.generate_invoice(...)`
2. A função calcula `total_food`, `total_drink`, aplica os impostos e grava na `invoice`
3. O app exibe o detalhamento ao cliente ou envia para o caixa

---

## 🔮 Melhorias futuras

* Suporte a formas de pagamento
* Integração com sistemas de emissão fiscal
* Armazenamento de QR Code, NFe ou comprovante digital
