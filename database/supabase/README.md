# 🍻 BotecoPro Database (Supabase)

Repositório oficial contendo **toda a infraestrutura de banco de dados** do projeto **BotecoPro**, organizada por *schemas* no Supabase.

> **Objetivo:** Facilitar versionamento, revisão de código SQL e automação de deploy (CI/CD) usando Supabase CLI e GitHub Actions.

---

## 📂 Estrutura de Pastas

```
supabase/
├── schemas/             # Um diretório por domínio de negócio
│   ├── core/            # Catálogo de receitas / ingredientes
│   │   ├── tables.sql
│   │   ├── functions.sql
│   │   ├── rls.sql
│   │   └── README.md
│   ├── order/           # Pedidos e comandas
│   ├── invoice/         # Faturas
│   ├── client/          # Clientes e mesas
│   ├── inventory/       # Fornecedores
│   └── staff/           # Funcionários
│
├── openapi/             # Contrato OpenAPI usado para gerar SDKs (Flutter, Web…)
│   └── openapi.yaml
└── README.md            # Este arquivo
```

Cada *schema* contém **quatro** arquivos‑chave:

| Arquivo         | Função                                                       |
| --------------- | ------------------------------------------------------------ |
| `tables.sql`    | Criação de tabelas e FKs                                     |
| `functions.sql` | Funções PL/pgSQL expostas como RPC (quando aplicável)        |
| `rls.sql`       | Políticas **Row‑Level Security** e permissões                |
| `README.md`     | Documentação do domínio (objetivo, fluxo, melhorias futuras) |

---

## 🛠️ Como Usar

### 1. Clonar & Inicializar Supabase CLI

```bash
git clone https://github.com/monynha/botecopro-db.git
cd botecopro-db
supabase init
```

### 2. Configurar `config.toml`

```toml
[db]
schemas = ["public", "core", "order", "invoice", "client", "inventory", "staff", "auth"]
```

### 3. Deploy local ou remoto

```bash
supabase db push          # aplica tudo na instância alvo
```

### 4. Seed opcional

Coloque scripts em `seed/` e execute conforme necessário.

---

## 🚀 CI/CD com GitHub Actions

Um workflow de exemplo (`.github/workflows/deploy-db.yml`) aplica migrações sempre que arquivos em `schemas/`, `views/` ou `seed/` forem alterados.

```yaml
uses: supabase/setup-cli@v1
run: supabase db push
```

Adicione o token `SUPABASE_ACCESS_TOKEN` em *Settings → Secrets → Actions*.

---

## 🗺️ Roadmap (Banco)

* [ ] Adicionar módulo de **Work Hours** no schema `staff`
* [ ] Função `core.calculate_recipe_cost()`
* [ ] Triggers de auditoria global
* [ ] Tests automatizados com `pgTAP`

Contribuições são bem‑vindas! Abra um *issue* ou *pull request* ✨
