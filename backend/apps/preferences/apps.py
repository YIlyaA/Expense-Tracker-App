from django.apps import AppConfig


class PreferencesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.preferences"
    label = "preferences"
    verbose_name = "Preferences"

    def ready(self) -> None:
        from . import signals  # noqa: F401
