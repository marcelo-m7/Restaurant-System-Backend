import reflex as rx


class BaseState(rx.State):
    """The base state for shared UI logic."""

    show_mobile_menu: bool = False

    @rx.event
    def toggle_mobile_menu(self):
        """Toggles the visibility of the mobile menu."""
        self.show_mobile_menu = not self.show_mobile_menu