from collections.abc import Iterable

from django.core.exceptions import ImproperlyConfigured


def validate_setting_choice(
    value: str,
    *,
    supported_values: Iterable[str],
    setting_name: str,
) -> str:
    supported_values_tuple = tuple(supported_values)

    if value not in supported_values_tuple:
        supported_values_display = ", ".join(supported_values_tuple)
        raise ImproperlyConfigured(
            f"{setting_name} must be one of: {supported_values_display}."
        )

    return value
