✅ Funcionalidades Implementadas
🔐 Autenticação Clerk - Login, signup, recuperação de senha
📊 Dashboard - KPIs em tempo real (mesas ativas, vendas, estoque baixo)
🪑 Gerenciamento de Mesas - Criar, editar, gerenciar status
📦 Catálogo de Produtos - Inventário com preço, estoque, categoria
🔄 Gerenciamento de Pedidos - Criar pedidos por mesa, marcar preparação
📖 Receitas - Definir receitas com ingredientes
🏭 Produção Interna - Rastrear produção caseira
👥 Fornecedores - Manter contatos de fornecedores
💾 Persistência - localStorage - dados persistem entre sessões
📱 Responsive - Funciona desktop, tablet e mobile


---

Banco de dados Supabase (schema public)

organize o sql abaixo para melhorar a leitura:

CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    username TEXT NOT NULL UNIQUE,
    tax_number TEXT NOT NULL UNIQUE,                     -- user tax number (obrigatório e único)
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    country TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    house_number TEXT NOT NULL,
    associated_establishment_name TEXT,                  -- optional
    establishment_tax_number TEXT,                       -- optional
    is_owner BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.boteco (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- identificação do comércio
    public_name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,                       -- commerce username (e.g., bardojonas)

    -- categoria e perfil
    service_category TEXT NOT NULL,
    offered_products_services TEXT,                      -- optional text, array or jsonb later
    average_staff_count INT,
    social_links JSONB,
    has_own_digital_infra BOOLEAN NOT NULL DEFAULT FALSE,
    vibe_tags TEXT[],

    -- dados fiscais e de localização
    establishment_tax_number TEXT,                       -- optional
    country TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    owner_tax_number TEXT NOT NULL UNIQUE,               -- owner tax number (obrigatório e único)

    -- referência pública (opcional)
    reference TEXT,

    -- auditoria
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_email TEXT NOT NULL,

    -- referência ao usuário criador (opcional, mas FK válida)
    created_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL
);

CREATE TABLE public.user_boteco (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    boteco_id UUID NOT NULL REFERENCES public.boteco(id) ON DELETE CASCADE,

    assigned_role TEXT NOT NULL DEFAULT 'owner',              -- papel do usuário neste boteco (owner, manager, staff, etc)
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),           -- data/hora da associação

    -- referência pública/operação
    reference TEXT,                                           -- padrão: boteco_username_timestamp, se necessário

    -- plano de assinatura adquirido
    plan TEXT NOT NULL CHECK (
        plan IN ('boteco', 'boteco_pro', 'boteco_patrao', 'boteco_babadeiro')
    ),

    -- auditoria
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
