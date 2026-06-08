from decimal import Decimal

from django.db import models

from apps.common.enums import CurrencyCode


class ExchangeRate(models.Model):
    currency = models.CharField(
        max_length=3,
        choices=CurrencyCode.choices(),
        unique=True,
    )
    rate_to_base = models.DecimalField(max_digits=14, decimal_places=6)
    source = models.CharField(max_length=64)
    fetched_at = models.DateTimeField(auto_now=True)
    effective_date = models.DateField()

    class Meta:
        verbose_name = "exchange rate"
        verbose_name_plural = "exchange rates"
        ordering = ("currency",)

    def __str__(self) -> str:
        return f"1 {self.currency} = {self.rate_to_base} (@ {self.effective_date})"

    @property
    def rate_to_base_decimal(self) -> Decimal:
        return Decimal(self.rate_to_base)
