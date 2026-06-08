from django.conf import settings
from django.db import models

from apps.categories.models import Category
from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import CurrencyCode


class Transaction(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="transactions",
    )
    client_id = models.UUIDField(null=True, blank=True)
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name="transactions",
    )
    description = models.CharField(max_length=255, blank=True, default="")
    original_amount = models.DecimalField(max_digits=12, decimal_places=2)
    original_currency = models.CharField(max_length=3, choices=CurrencyCode.choices())
    base_amount = models.DecimalField(max_digits=12, decimal_places=2)
    base_currency = models.CharField(
        max_length=3,
        choices=CurrencyCode.choices(),
        default=SYSTEM_BASE_CURRENCY_CODE,
    )
    transaction_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("-transaction_date", "-created_at", "-id")
        verbose_name = "transaction"
        verbose_name_plural = "transactions"
        constraints = [
            models.UniqueConstraint(
                fields=("user", "client_id"),
                condition=models.Q(client_id__isnull=False),
                name="uniq_transaction_user_client_id",
            ),
        ]
        indexes = [
            models.Index(fields=("user", "transaction_date")),
            models.Index(fields=("user", "category", "transaction_date")),
            models.Index(fields=("user", "updated_at")),
        ]

    def __str__(self) -> str:
        return f"{self.user.email}: {self.original_amount} {self.original_currency}"
