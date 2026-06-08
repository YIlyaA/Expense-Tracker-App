import pytest
from django.conf import settings
from django.core.exceptions import ImproperlyConfigured

from apps.common import (
    DEFAULT_CURRENCY_CODE,
    DEFAULT_LANGUAGE_CODE,
    SUPPORTED_CURRENCY_CODES,
    SUPPORTED_LANGUAGE_CODES,
    SYSTEM_BASE_CURRENCY_CODE,
    AppLanguage,
    CurrencyCode,
    ExpenseCategoryCode,
)
from apps.common.validators import validate_setting_choice


def test_supported_languages_are_exposed_in_settings():
    assert settings.LANGUAGE_CODE == DEFAULT_LANGUAGE_CODE
    assert settings.LANGUAGES == AppLanguage.choices()
    assert settings.SUPPORTED_LANGUAGE_CODES == SUPPORTED_LANGUAGE_CODES
    assert settings.LOCALE_PATHS == [settings.BASE_DIR / "locale"]
    assert (settings.BASE_DIR / "locale").exists()


def test_locale_middleware_is_enabled_in_the_correct_order():
    middleware = settings.MIDDLEWARE
    locale_middleware = "django.middleware.locale.LocaleMiddleware"
    session_middleware = "django.contrib.sessions.middleware.SessionMiddleware"
    common_middleware = "django.middleware.common.CommonMiddleware"

    assert locale_middleware in middleware
    assert middleware.index(session_middleware) < middleware.index(locale_middleware)
    assert middleware.index(locale_middleware) < middleware.index(common_middleware)


def test_shared_enums_cover_languages_currencies_and_category_codes():
    assert AppLanguage.values() == ("en", "pl", "ru")
    assert CurrencyCode.values() == ("PLN", "USD", "EUR")
    assert ExpenseCategoryCode.values() == (
        "food",
        "transport",
        "phone",
        "sport",
        "household",
        "health",
        "documents",
        "clothes_items",
        "subscriptions_education",
        "top_ups",
        "other",
    )
    assert DEFAULT_CURRENCY_CODE == CurrencyCode.PLN.value
    assert SYSTEM_BASE_CURRENCY_CODE == CurrencyCode.PLN.value
    assert SUPPORTED_CURRENCY_CODES == CurrencyCode.values()


def test_validate_setting_choice_rejects_unsupported_values():
    assert (
        validate_setting_choice(
            "pl",
            supported_values=AppLanguage.values(),
            setting_name="DJANGO_LANGUAGE_CODE",
        )
        == "pl"
    )

    with pytest.raises(ImproperlyConfigured, match="DJANGO_LANGUAGE_CODE"):
        validate_setting_choice(
            "de",
            supported_values=AppLanguage.values(),
            setting_name="DJANGO_LANGUAGE_CODE",
        )
