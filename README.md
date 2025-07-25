# 🍻 BotecoPro **Backend** (Monorepo)

Repositório **monolítico** que concentra **todo o código de backend** do ecossistema **BotecoPro**, incluindo a camada de dados Supabase e serviços adjacentes.

> Este repo torna simples a gerência de dependências, CI/CD e versionamento de múltiplos componentes que evoluem em conjunto.

---

## 🗂️ Estrutura de Diretórios

```
backend/
├── database/                 # → Submódulo "BotecoPro Database (Supabase)"
│   └── supabase/             #   - schemas, RLS, funções, openapi.yaml…
│
├── edge-functions/           # Supabase Edge Functions (TypeScript)
│   └── order-webhook.ts
│
├── services/                 # Serviços auxiliares (ex: cron, notificações)
│   ├── stock-alerts/
│   └── billing-sync/
│
├── .github/workflows/        # Workflows CI/CD (lint, test, deploy)
└── README.md                 # Você está aqui
```

### Sub‑repositório **database/**

Contém o schema-driven **BotecoPro DB (Supabase)**, organizado por domínios (`core`, `order`, `invoice`, …) com:

* `tables.sql`, `functions.sql`, `rls.sql` e `README.md` por schema
* Contrato **OpenAPI** (`openapi/openapi.yaml`) usado para gerar SDKs (Flutter, Web)

---

## 🚀 Como rodar localmente

### Pré‑requisitos

* **Node 20+** (Edge Functions)
* **Supabase CLI** (`brew install supabase`) — para banco local e migrations

### Passos rápidos

```bash
# 1) Clonar e instalar dependências
pnpm install  # ou npm/yarn

# 2) Iniciar Supabase local (inclui Postgres + Auth + Edge Functions)
supabase start

# 3) Aplicar migrations do banco
task db:push      # ou `supabase db push`

# 4) Rodar edge functions em dev hot‑reload
supabase functions serve --watch
```

---

## 🔄 CI/CD

* **Deploy banco**: GitHub Actions dispara `supabase db push` ao mudar `database/supabase/schemas/**`
* **Deploy functions**: outro workflow faz `supabase functions deploy` a cada merge na *main*

Secrets necessários:

* `SUPABASE_ACCESS_TOKEN`
* `SUPABASE_PROJECT_REF`

---

## 📌 Roadmap

* [ ] **Work Hours API** — registro de carga horária dos funcionários
* [ ] **Inventory Cron** — job diário para gerar pedidos automáticos de reposição
* [ ] **Billing Integration** — integração Stripe → Invoice

Pull requests e issues são bem‑vindos! 💬
