from decimal import ROUND_HALF_UP, Decimal

from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import CurrencyCode
from apps.currency.services import get_rate_source, get_rate_to_base

MONEY_QUANTIZE_EXPONENT = Decimal("0.01")

TEMPORARY_REFERENCE_RATE_SOURCE = "exchange_rate_provider"

MAX_BASE_AMOUNT = Decimal("9999999999.99")


class BaseAmountOverflowError(ValueError):
    pass


def quantize_money(value: Decimal) -> Decimal:
    return value.quantize(MONEY_QUANTIZE_EXPONENT, rounding=ROUND_HALF_UP)


def _assert_pln_base() -> None:
    if SYSTEM_BASE_CURRENCY_CODE != CurrencyCode.PLN.value:
        raise ValueError(
            "Conversion service currently expects PLN as the system base currency."
        )


def calculate_base_amount(*, original_amount: Decimal, original_currency: str) -> Decimal:
    _assert_pln_base()
    conversion_rate = get_rate_to_base(original_currency)
    base = quantize_money(original_amount * conversion_rate)
    if base > MAX_BASE_AMOUNT:
        raise BaseAmountOverflowError(
            f"Converted amount {base} exceeds the storage limit {MAX_BASE_AMOUNT}."
        )
    return base


def convert_base_amount_to_display(*, base_amount: Decimal, display_currency: str) -> Decimal:
    _assert_pln_base()
    conversion_rate = get_rate_to_base(display_currency)
    return quantize_money(base_amount / conversion_rate)


def get_active_conversion_source(*, display_currency: str) -> str:
    return get_rate_source(display_currency)
