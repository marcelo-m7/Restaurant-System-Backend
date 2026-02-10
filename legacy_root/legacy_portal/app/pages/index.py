import reflex as rx
from app.components.header import header
from app.components.footer import footer


def feature_card(icon: str, title: str, description: str) -> rx.Component:
    """Card for 'How it Works' section."""
    return rx.el.div(
        rx.icon(tag=icon, class_name="h-10 w-10 text-[#B3701A]"),
        rx.el.h3(title, class_name="mt-5 text-lg font-semibold text-[#4F3222]"),
        rx.el.p(description, class_name="mt-2 text-base text-[#4F3222] opacity-80"),
        class_name="p-6 bg-white rounded-xl shadow-md border border-gray-200/50 hover:shadow-lg hover:-translate-y-1 transition-all duration-300",
    )


def plan_preview_card(
    title: str, description: str, tag: str | None = None
) -> rx.Component:
    """Card for 'Plans Preview' section."""
    return rx.el.div(
        rx.cond(
            tag is not None,
            rx.el.span(
                tag,
                class_name="absolute top-0 right-0 -mt-3 mr-3 px-3 py-1 bg-[#B3701A] text-white text-xs font-bold rounded-full uppercase",
            ),
        ),
        rx.el.h3(title, class_name="text-xl font-bold text-[#8B1E3F]"),
        rx.el.p(description, class_name="mt-2 text-sm text-[#4F3222] opacity-80 h-12"),
        class_name="relative p-6 bg-white rounded-xl shadow-md border border-gray-200/50 h-full",
    )


def index() -> rx.Component:
    """The landing page of the application."""
    return rx.el.main(
        header(),
        rx.el.section(
            rx.el.div(
                rx.el.div(
                    rx.el.h1(
                        "Transforme seu Boteco em um Negócio Profissional",
                        class_name="text-4xl md:text-6xl font-extrabold text-[#4F3222] tracking-tight",
                    ),
                    rx.el.p(
                        "A plataforma completa para gerenciar mesas, pedidos, estoque e muito mais. Deixe a burocracia com a gente e foque no que importa: seus clientes.",
                        class_name="mt-4 max-w-xl text-lg text-[#4F3222] opacity-90",
                    ),
                    rx.el.div(
                        rx.el.a(
                            "Comece Agora",
                            href="/sign-up",
                            class_name="inline-flex items-center justify-center px-8 py-3 border border-transparent text-base font-medium rounded-lg text-white bg-gradient-to-r from-[#8B1E3F] to-[#a13b5a] hover:from-[#7a1a37] hover:to-[#8B1E3F] shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 transition-all duration-300",
                        ),
                        rx.el.a(
                            "Ver Planos",
                            href="/pricing",
                            class_name="ml-4 inline-flex items-center justify-center px-8 py-3 border border-[#B3701A] text-base font-medium rounded-lg text-[#B3701A] bg-white/80 hover:bg-white transition-colors shadow-md hover:shadow-lg transform hover:-translate-y-0.5",
                        ),
                        class_name="mt-8 flex flex-wrap gap-4",
                    ),
                ),
                rx.el.div(
                    rx.image(
                        src="/placeholder.svg",
                        alt="Ilustração do sistema Barnostri em um tablet",
                        class_name="rounded-xl shadow-2xl w-full h-auto object-cover",
                    ),
                    class_name="hidden lg:block mt-12 lg:mt-0 lg:ml-12 w-full lg:w-1/2",
                ),
                class_name="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 lg:py-24 grid lg:grid-cols-2 items-center gap-12",
            ),
            class_name="bg-[#F1DDAD]",
        ),
        rx.el.section(
            rx.el.div(
                rx.el.h2(
                    "Como funciona",
                    class_name="text-3xl font-bold text-[#8B1E3F] text-center",
                ),
                rx.el.p(
                    "Comece a operar em 4 passos simples.",
                    class_name="mt-4 text-lg text-center text-[#4F3222] opacity-80",
                ),
                rx.el.div(
                    feature_card(
                        "user-plus",
                        "1. Cadastre-se",
                        "Crie sua conta em minutos. Informações básicas para começar a sua jornada.",
                    ),
                    feature_card(
                        "store",
                        "2. Configure seu Boteco",
                        "Adicione os detalhes do seu estabelecimento, como nome, categoria e produtos.",
                    ),
                    feature_card(
                        "credit-card",
                        "3. Escolha seu Plano",
                        "Selecione o plano que melhor se adapta ao tamanho e às necessidades do seu negócio.",
                    ),
                    feature_card(
                        "rocket",
                        "4. Comece a Operar",
                        "Pronto! Acesse seu painel e comece a gerenciar seu boteco de forma profissional.",
                    ),
                    class_name="mt-12 grid gap-8 md:grid-cols-2 lg:grid-cols-4",
                ),
                class_name="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8",
            ),
            class_name="bg-white",
        ),
        rx.el.section(
            rx.el.div(
                rx.el.h2(
                    "Planos para todos os tamanhos de sede",
                    class_name="text-3xl font-bold text-[#8B1E3F] text-center",
                ),
                rx.el.p(
                    "Do boteco da esquina à rede de bares, temos a solução certa.",
                    class_name="mt-4 text-lg text-center text-[#4F3222] opacity-80",
                ),
                rx.el.div(
                    plan_preview_card(
                        "Boteco (Básico)",
                        "Ideal para começar a organizar a casa. Gestão de mesas e pedidos.",
                    ),
                    plan_preview_card(
                        "Boteco Pro (Recomendado)",
                        "Para quem quer crescer. Controle de estoque, receitas e dashboard.",
                        tag="Recomendado",
                    ),
                    plan_preview_card(
                        "Boteco Patrão",
                        "Gestão completa. Múltiplos usuários, relatórios e fornecedores.",
                    ),
                    plan_preview_card(
                        "Boteco Babadeiro",
                        "Para os grandes. Suporte VIP, customizações e multi-unidades.",
                    ),
                    class_name="mt-12 grid gap-8 md:grid-cols-2 lg:grid-cols-4",
                ),
                rx.el.div(
                    rx.el.a(
                        "Ver todos os detalhes dos planos",
                        href="/pricing",
                        class_name="inline-flex items-center text-[#8B1E3F] font-semibold hover:text-[#B3701A] transition-colors",
                    ),
                    class_name="mt-12 text-center",
                ),
                class_name="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8",
            ),
            class_name="bg-[#F1DDAD]/60",
        ),
        rx.el.section(
            rx.el.div(
                rx.el.div(
                    rx.el.h2(
                        "Nossa Missão", class_name="text-3xl font-bold text-[#4F3222]"
                    ),
                    rx.el.p(
                        "A Barnostri nasceu para empoderar donos de botecos e restaurantes em todo o Brasil, fornecendo tecnologia de ponta de um jeito simples e acessível. Acreditamos que a gestão eficiente é o ingrediente secreto para o sucesso.",
                        class_name="mt-4 text-lg text-[#4F3222] opacity-80",
                    ),
                    rx.el.a(
                        "Saiba mais sobre nós",
                        href="/about",
                        class_name="mt-6 inline-flex items-center text-base font-semibold text-[#8B1E3F] hover:text-[#B3701A] transition-colors",
                    ),
                ),
                rx.el.div(
                    rx.image(
                        src="/placeholder.svg",
                        alt="Foto da equipe Barnostri",
                        class_name="rounded-xl shadow-lg w-full h-auto object-cover",
                    ),
                    class_name="hidden md:block w-full md:w-1/2",
                ),
                class_name="max-w-7xl mx-auto grid md:grid-cols-2 gap-12 items-center py-16 px-4 sm:px-6 lg:px-8",
            ),
            class_name="bg-white",
        ),
        footer(),
        class_name="font-['Inter']",
    )