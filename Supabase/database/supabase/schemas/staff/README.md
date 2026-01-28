# 👥 Schema: `staff`

O schema `staff` representa o módulo de **gestão de funcionários** do BotecoPro. Ele contém os dados básicos dos colaboradores que interagem com o sistema, como garçons, gerentes, cozinheiros, etc.

---

## 📐 Estrutura

### Tabela

* `employee`: cadastro dos funcionários, incluindo nome, cargo e valor/hora

> A coluna `role` permite aplicar lógicas de acesso via RLS e Supabase Auth.

### Funções

Não possui RPCs diretas, mas é referenciado em pedidos (`order_main.employee_id`) e pode ser usado para cálculo de folha no futuro.

---

## 🔐 RLS

Não foram ativadas políticas neste schema, pois espera-se que apenas usuários com permissão administrativa tenham acesso à tabela via painel interno ou scripts internos.

---

## 📊 Uso no app

* Seleção do funcionário logado ao registrar pedidos
* Controle de acesso via JWT (`role`)

---

## 🔮 Melhorias futuras

* Tabela `work_hour` para registrar carga horária mensal
* Integração com folha de pagamento
* Login separado por função e segurança reforçada
