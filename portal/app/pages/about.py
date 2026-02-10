import reflex as rx
from app.components.header import header
from app.components.footer import footer


def info_card(icon: str, title: str, description: str) -> rx.Component:
    """A card for displaying company values."""
    return rx.el.div(
        rx.icon(tag=icon, class_name="h-10 w-10 text-[#B3701A]"),
        rx.el.h3(title, class_name="mt-4 text-xl font-semibold text-[#4F3222]"),
        rx.el.p(description, class_name="mt-2 text-base text-[#4F3222] opacity-80"),
        class_name="p-8 bg-white rounded-xl shadow-md border border-gray-200/50 hover:shadow-lg hover:-translate-y-1 transition-all duration-300",
    )


def team_member_card(name: str, role: str, image_url: str) -> rx.Component:
    """A card for displaying a team member."""
    initials = "".join((n[0] for n in name.split()))[:2].upper()
    return rx.el.div(
        rx.cond(
            image_url == "/placeholder.svg",
            rx.el.div(
                rx.el.span(initials, class_name="text-3xl font-bold text-[#8B1E3F]"),
                class_name="h-32 w-32 rounded-full mx-auto bg-[#F1DDAD] flex items-center justify-center border-2 border-[#8B1E3F]/20",
            ),
            rx.image(
                src=image_url,
                alt=name,
                class_name="h-32 w-32 rounded-full mx-auto object-cover",
            ),
        ),
        rx.el.h3(name, class_name="mt-4 text-lg font-medium text-[#4F3222]"),
        rx.el.p(role, class_name="text-[#B3701A] text-sm font-semibold"),
        class_name="text-center",
    )


def about() -> rx.Component:
    """The About Us page."""
    return rx.el.main(
        header(),
        rx.el.section(
            rx.el.div(
                rx.el.h1(
                    "Sobre a Barnostri",
                    class_name="text-4xl md:text-5xl font-extrabold text-[#8B1E3F] tracking-tight text-center",
                ),
                rx.el.p(
                    "Nossa missão é fortalecer a cultura do boteco brasileiro através da tecnologia, oferecendo ferramentas que simplificam a gestão e impulsionam o crescimento de pequenos e médios estabelecimentos.",
                    class_name="mt-6 max-w-3xl mx-auto text-lg text-[#4F3222] text-center opacity-90",
                ),
                class_name="max-w-7xl mx-auto py-16 px-4 sm:py-24 sm:px-6 lg:px-8",
            ),
            class_name="bg-[#F1DDAD]/60",
        ),
        rx.el.section(
            rx.el.div(
                rx.el.div(
                    rx.el.h2(
                        "Nossa História", class_name="text-3xl font-bold text-[#4F3222]"
                    ),
                    rx.el.p(
                        "A Barnostri nasceu da paixão por botecos e da percepção de que muitos donos de bar, verdadeiros artesãos da hospitalidade, enfrentavam desafios diários com processos manuais e pouco eficientes. Decidimos criar uma plataforma que fosse a cara do Brasil: robusta, mas fácil de usar; completa, mas sem complicação. Queremos ser o parceiro que ajuda a transformar a paixão em um negócio ainda mais próspero.",
                        class_name="mt-4 text-lg text-[#4F3222] opacity-80",
                    ),
                    rx.el.p(
                        "Desde o controle de uma simples comanda até a gestão completa de estoque e receitas, nosso sistema foi pensado para o dia a dia do boteco, permitindo que o dono foque no que faz de melhor: atender bem seus clientes.",
                        class_name="mt-4 text-lg text-[#4F3222] opacity-80",
                    ),
                ),
                class_name="max-w-4xl mx-auto py-16 px-4 sm:px-6 lg:px-8",
            )
        ),
        rx.el.section(
            rx.el.div(
                rx.el.h2(
                    "Nossos Valores",
                    class_name="text-3xl font-bold text-[#8B1E3F] text-center",
                ),
                rx.el.div(
                    info_card(
                        "zap",
                        "Simplicidade",
                        "Criamos ferramentas intuitivas que qualquer pessoa pode usar, sem necessidade de treinamento extensivo. A tecnologia deve facilitar, não complicar.",
                    ),
                    info_card(
                        "trending-up",
                        "Eficiência",
                        "Nosso objetivo é otimizar operações, reduzir desperdícios e aumentar a lucratividade do seu negócio. Mais tempo para você, mais lucro no caixa.",
                    ),
                    info_card(
                        "heart-handshake",
                        "Suporte Local",
                        "Entendemos a realidade brasileira. Oferecemos suporte próximo e em português, pronto para ajudar a resolver os desafios específicos do seu boteco.",
                    ),
                    class_name="mt-12 grid gap-8 md:grid-cols-3",
                ),
                class_name="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8",
            ),
            class_name="bg-[#F1DDAD]/60",
        ),
        rx.el.section(
            rx.el.div(
                rx.el.h2(
                    "Conheça o Time (Placeholder)",
                    class_name="text-3xl font-bold text-[#4F3222] text-center",
                ),
                rx.el.div(
                    team_member_card(
                        "Ana Silva", "CEO & Co-fundadora", "/placeholder.svg"
                    ),
                    team_member_card(
                        "Carlos Souza", "CTO & Co-fundador", "/placeholder.svg"
                    ),
                    team_member_card(
                        "Mariana Lima", "Chefe de Produto", "/placeholder.svg"
                    ),
                    team_member_card(
                        "João Pereira",
                        "Líder de Sucesso do Cliente",
                        "/placeholder.svg",
                    ),
                    class_name="mt-12 grid gap-12 sm:grid-cols-2 lg:grid-cols-4",
                ),
                class_name="max-w-7xl mx-auto py-16 px-4 sm:px-6 lg:px-8",
            )
        ),
        rx.el.section(
            rx.el.div(
                rx.el.h2(
                    "Pronto para transformar seu negócio?",
                    class_name="text-3xl font-extrabold text-white",
                ),
                rx.el.a(
                    "Veja nossos planos",
                    href="/pricing",
                    class_name="mt-8 w-full inline-flex items-center justify-center px-6 py-3 border border-transparent rounded-md shadow-sm text-base font-medium text-[#8B1E3F] bg-white hover:bg-gray-50 sm:w-auto transition-colors",
                ),
                class_name="max-w-2xl mx-auto text-center py-16 px-4 sm:py-20 sm:px-6 lg:px-8",
            ),
            class_name="bg-[#8B1E3F]",
        ),
        footer(),
        class_name="bg-white font-['Inter']",
    )