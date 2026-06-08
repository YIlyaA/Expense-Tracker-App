from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from threading import RLock

from django.db import transaction as db_transaction

from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import CurrencyCode

from .models import ExchangeRate
from .providers import (
    FOREIGN_CURRENCIES,
    ExchangeRateProvider,
    FetchedRate,
    get_default_provider,
)

logger = logging.getLogger(__name__)


SEED_RATES: dict[str, Decimal] = {
    CurrencyCode.USD.value: Decimal("4.0000"),
    CurrencyCode.EUR.value: Decimal("4.3000"),
}
SEED_SOURCE = "seed_default_v1"


_cache_lock = RLock()
_cache: dict[str, Decimal] | None = None


def _load_cache_locked() -> dict[str, Decimal]:
    rates: dict[str, Decimal] = {SYSTEM_BASE_CURRENCY_CODE: Decimal("1")}
    rows = list(ExchangeRate.objects.all())
    for row in rows:
        rates[row.currency] = Decimal(row.rate_to_base)
    for code, seed_rate in SEED_RATES.items():
        rates.setdefault(code, seed_rate)
    return rates


def _get_cache() -> dict[str, Decimal]:
    global _cache
    with _cache_lock:
        if _cache is None:
            _cache = _load_cache_locked()
        return _cache


def invalidate_cache() -> None:
    global _cache
    with _cache_lock:
        _cache = None


def get_rate_to_base(currency: str) -> Decimal:
    rates = _get_cache()
    try:
        return rates[currency]
    except KeyError as exc:
        raise ValueError(
            f"Unsupported currency for base conversion: {currency}"
        ) from exc


def get_rate_source(currency: str) -> str:
    if currency == SYSTEM_BASE_CURRENCY_CODE:
        return "identity"
    row = ExchangeRate.objects.filter(currency=currency).only("source").first()
    if row is not None:
        return row.source
    if currency in SEED_RATES:
        return SEED_SOURCE
    return "unknown"


@dataclass(frozen=True, slots=True)
class RefreshResult:
    fetched: list[FetchedRate]
    updated_currencies: list[str]
    source_name: str

    @property
    def updated_count(self) -> int:
        return len(self.updated_currencies)


def refresh_rates_from_provider(
    provider: ExchangeRateProvider | None = None,
) -> RefreshResult:
    provider = provider or get_default_provider()
    fetched = provider.fetch_latest()

    updated: list[str] = []
    with db_transaction.atomic():
        for rate in fetched:
            if rate.currency == SYSTEM_BASE_CURRENCY_CODE:
                continue
            ExchangeRate.objects.update_or_create(
                currency=rate.currency,
                defaults={
                    "rate_to_base": rate.rate_to_base,
                    "source": rate.source,
                    "effective_date": rate.effective_date,
                },
            )
            updated.append(rate.currency)

    invalidate_cache()
    logger.info(
        "Refreshed %d exchange rates from %s.", len(updated), provider.source_name,
    )
    return RefreshResult(
        fetched=fetched,
        updated_currencies=updated,
        source_name=provider.source_name,
    )


def seed_rates_if_missing() -> None:
    today = date.today()
    created_any = False
    for code in FOREIGN_CURRENCIES:
        if code not in SEED_RATES:
            continue
        _, created = ExchangeRate.objects.get_or_create(
            currency=code,
            defaults={
                "rate_to_base": SEED_RATES[code],
                "source": SEED_SOURCE,
                "effective_date": today,
            },
        )
        created_any = created_any or created
    if created_any:
        invalidate_cache()
