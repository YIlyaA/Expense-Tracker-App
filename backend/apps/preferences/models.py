from django.conf import settings
from django.db import models

from apps.common.constants import DEFAULT_CURRENCY_CODE, DEFAULT_LANGUAGE_CODE
from apps.common.enums import AppLanguage, CurrencyCode


class UserSettings(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="settings",
    )
    preferred_language = models.CharField(
        max_length=8,
        choices=AppLanguage.choices(),
        default=DEFAULT_LANGUAGE_CODE,
    )
    preferred_currency = models.CharField(
        max_length=3,
        choices=CurrencyCode.choices(),
        default=DEFAULT_CURRENCY_CODE,
    )
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "user settings"
        verbose_name_plural = "user settings"

    def __str__(self) -> str:
        return f"Settings for {self.user.email}"
