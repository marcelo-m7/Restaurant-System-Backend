import reflex as rx
import reflex_clerk_api as clerk
from app.states.onboarding_state import OnboardingState
from app.components.onboarding_stepper import onboarding_stepper


def form_field(
    label: str,
    placeholder: str,
    value: rx.Var,
    on_change: rx.event.EventHandler,
    name: str,
    field_type: str = "text",
    disabled: bool = False,
) -> rx.Component:
    return rx.el.div(
        rx.el.label(label, class_name="block text-sm font-medium text-[#4F3222]"),
        rx.el.input(
            placeholder=placeholder,
            on_change=on_change,
            name=name,
            type=field_type,
            disabled=disabled,
            class_name="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-[#B3701A] focus:border-[#B3701A] sm:text-sm disabled:bg-gray-100 disabled:text-gray-500",
            default_value=value,
        ),
        class_name="col-span-6 sm:col-span-3",
    )


def personal_step() -> rx.Component:
    return rx.el.main(
        rx.el.div(
            rx.el.div(
                rx.el.a(
                    "Barnostri",
                    href="/",
                    class_name="text-2xl font-bold text-[#8B1E3F] hover:opacity-90 transition-opacity",
                ),
                class_name="py-8 px-4 sm:px-6 lg:px-8 bg-[#F1DDAD]/50 border-b border-gray-200",
            ),
            onboarding_stepper(OnboardingState.current_step),
            rx.el.div(
                rx.el.h2(
                    "Passo 1: Seus Dados Pessoais",
                    class_name="text-2xl font-bold text-[#4F3222]",
                ),
                rx.el.p(
                    "Confirme seus dados e preencha o que falta. Alguns campos são preenchidos automaticamente pela sua conta.",
                    class_name="mt-2 text-sm text-[#4F3222]/80",
                ),
                rx.el.form(
                    rx.el.div(
                        form_field(
                            "Nome",
                            "",
                            clerk.ClerkUser.first_name,
                            OnboardingState.set_personal_first_name,
                            name="personal_first_name",
                            disabled=True,
                        ),
                        form_field(
                            "Sobrenome",
                            "",
                            clerk.ClerkUser.last_name,
                            OnboardingState.set_personal_last_name,
                            name="personal_last_name",
                            disabled=True,
                        ),
                        form_field(
                            "Email",
                            "",
                            clerk.ClerkUser.email_address,
                            OnboardingState.set_personal_email,
                            name="personal_email",
                            field_type="email",
                            disabled=True,
                        ),
                        form_field(
                            "CPF",
                            "XXX.XXX.XXX-XX",
                            OnboardingState.personal_tax_number,
                            OnboardingState.set_personal_tax_number,
                            name="personal_tax_number",
                        ),
                        form_field(
                            "Data de Nascimento",
                            "",
                            OnboardingState.personal_birth_date,
                            OnboardingState.set_personal_birth_date,
                            name="personal_birth_date",
                            field_type="date",
                        ),
                        form_field(
                            "País",
                            "Brasil",
                            OnboardingState.personal_country,
                            OnboardingState.set_personal_country,
                            name="personal_country",
                        ),
                        form_field(
                            "CEP",
                            "XXXXX-XXX",
                            OnboardingState.personal_postal_code,
                            OnboardingState.set_personal_postal_code,
                            name="personal_postal_code",
                        ),
                        form_field(
                            "Número da Casa/Apto",
                            "123",
                            OnboardingState.personal_house_number,
                            OnboardingState.set_personal_house_number,
                            name="personal_house_number",
                        ),
                        class_name="grid grid-cols-6 gap-6 mt-6",
                    ),
                    rx.el.div(
                        rx.el.button(
                            rx.cond(
                                OnboardingState.is_loading,
                                rx.el.div(
                                    rx.spinner(class_name="h-4 w-4"),
                                    "Salvando...",
                                    class_name="flex items-center gap-2",
                                ),
                                "Continuar",
                            ),
                            type="submit",
                            is_disabled=OnboardingState.is_loading,
                            class_name="inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-[#8B1E3F] hover:bg-[#7a1a37] disabled:bg-gray-400",
                        ),
                        class_name="flex justify-end mt-8",
                    ),
                    on_submit=OnboardingState.handle_personal_submit,
                ),
                class_name="max-w-2xl mx-auto p-8 bg-white rounded-xl shadow-md border border-gray-200/80",
            ),
            class_name="pb-16",
        ),
        class_name="min-h-screen bg-[#F1DDAD]/30 font-['Inter']",
    )