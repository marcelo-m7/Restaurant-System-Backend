## 📁 Estrutura de Diretórios

```
/supabase/
├── config/
│   └── roles.sql                  # Roles e permissões padrão do projeto
│
├── schemas/
│   ├── core/
│   │   ├── tables.sql             # Tabelas como recipe, ingredient, etc.
│   │   ├── functions.sql          # RPCs ex: calculate_price, ...
│   │   └── rls.sql                # Políticas RLS do schema
│   │
│   ├── order/
│   │   ├── tables.sql             # order_main, order_item, etc.
│   │   ├── functions.sql          # create_order, add_item, confirm_order, ...
│   │   └── rls.sql
│   │
│   ├── invoice/
│   │   ├── tables.sql             # invoice
│   │   ├── functions.sql
│   │   └── rls.sql
│   │
│   ├── client/
│   │   ├── tables.sql             # client, table_seating
│   │   └── rls.sql
│   │
│   ├── staff/
│   │   └── tables.sql             # employee, future: shifts, work_hour
│   │
│   └── inventory/
│       ├── tables.sql             # supplier
│       └── rls.sql
│
├── views/
│   └── ingredients_below_min.sql # vw_IngredientesAbaixoEstoqueMinimo
│
├── extensions/
│   └── pgcrypto.sql              # json web token, uuid helpers, etc.
│
├── seed/
│   ├── categories.sql
│   ├── ingredients.sql
│   ├── recipes.sql
│   └── example_order.sql
│
├── openapi/
│   └── openapi.yaml              # Contrato para geração de clients
│
├── README.md
└── supabase/config.toml          # Arquivo de config do Supabase CLI
```

---

## ✅ Boas Práticas Aplicadas

* **Divisão por schema**: facilita migração parcial, modularização e controle granular.
* **RLS isolado**: ajuda no rastreio e versionamento seguro das permissões.
* **Seed separado**: permite popular localmente e em staging sem misturar com estrutura.
* **OpenAPI versionado**: suporte a geração automática de clientes (Flutter, Web, etc).

---

## 🛠️ Sugestão de comandos de deploy

```bash
# Criar um schema novo no Supabase
supabase db remote commit "Add order schema"
```

```bash
# Subir tudo
supabase db push
```
