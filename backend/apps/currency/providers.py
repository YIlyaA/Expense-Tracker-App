from __future__ import annotations

import json
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import date
from decimal import Decimal
from typing import Protocol

from django.conf import settings as django_settings

from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import CurrencyCode

FOREIGN_CURRENCIES: tuple[str, ...] = tuple(
    code for code in CurrencyCode.values() if code != SYSTEM_BASE_CURRENCY_CODE
)


@dataclass(frozen=True, slots=True)
class FetchedRate:
    currency: str
    rate_to_base: Decimal
    effective_date: date
    source: str


class ExchangeRateProvider(Protocol):
    source_name: str

    def fetch_latest(self) -> list[FetchedRate]:
        ...


class NBPExchangeRateProvider:
    source_name = "nbp_table_a_v1"
    _url = "https://api.nbp.pl/api/exchangerates/tables/A/?format=json"
    _timeout_seconds = 8

    def fetch_latest(self) -> list[FetchedRate]:
        with urllib.request.urlopen(self._url, timeout=self._timeout_seconds) as resp:
            payload = json.loads(resp.read().decode("utf-8"))

        if not payload:
            raise RuntimeError("NBP returned an empty payload.")
        table = payload[0]
        effective_str = table["effectiveDate"]
        effective = date.fromisoformat(effective_str)
        rates_by_currency = {entry["code"]: entry["mid"] for entry in table["rates"]}

        result: list[FetchedRate] = []
        for code in FOREIGN_CURRENCIES:
            mid = rates_by_currency.get(code)
            if mid is None:
                raise RuntimeError(f"NBP table A is missing rate for {code}.")
            rate = Decimal(str(mid)).quantize(Decimal("0.000001"))
            result.append(
                FetchedRate(
                    currency=code,
                    rate_to_base=rate,
                    effective_date=effective,
                    source=self.source_name,
                )
            )
        return result


def get_default_provider() -> ExchangeRateProvider:
    override = getattr(django_settings, "EXCHANGE_RATE_PROVIDER", None)
    if override is not None:
        return override
    return NBPExchangeRateProvider()
