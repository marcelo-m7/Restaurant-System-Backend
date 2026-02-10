import reflex as rx
from app.components.header import header
from app.components.footer import footer


def dashboard() -> rx.Component:
    return rx.el.main(
        header(),
        rx.el.div(
            rx.el.div(
                rx.el.h1(
                    "Bem-vindo ao seu Dashboard",
                    class_name="text-3xl font-bold text-[#4F3222] tracking-tight",
                ),
                rx.el.p(
                    "Ainda estamos construindo esta área. Por enquanto, seu negócio está configurado!",
                    class_name="mt-2 text-lg text-[#4F3222] opacity-80",
                ),
                rx.el.div(
                    rx.el.div(
                        rx.el.div(
                            rx.el.p(
                                "Vendas Hoje",
                                class_name="text-sm font-medium text-gray-500",
                            ),
                            rx.el.p(
                                "R$ 0,00",
                                class_name="text-2xl font-semibold text-gray-900",
                            ),
                            class_name="p-6 bg-white rounded-lg shadow-sm",
                        ),
                        rx.el.div(
                            rx.el.p(
                                "Mesas Ativas",
                                class_name="text-sm font-medium text-gray-500",
                            ),
                            rx.el.p(
                                "0", class_name="text-2xl font-semibold text-gray-900"
                            ),
                            class_name="p-6 bg-white rounded-lg shadow-sm",
                        ),
                        rx.el.div(
                            rx.el.p(
                                "Estoque Baixo",
                                class_name="text-sm font-medium text-gray-500",
                            ),
                            rx.el.p(
                                "0 itens",
                                class_name="text-2xl font-semibold text-gray-900",
                            ),
                            class_name="p-6 bg-white rounded-lg shadow-sm",
                        ),
                        class_name="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-3",
                    )
                ),
            ),
            class_name="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8",
        ),
        footer(),
        class_name="min-h-screen bg-[#F1DDAD]/30 font-['Inter']",
    )