from __future__ import annotations

from calendar import monthrange
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import ROUND_HALF_UP, Decimal

from django.db.models import Count, Sum, Value
from django.db.models.functions import Coalesce, TruncMonth
from django.utils import timezone

from apps.categories.defaults import get_category_definition
from apps.categories.models import Category
from apps.common.constants import DEFAULT_LANGUAGE_CODE
from apps.insights.enums import InsightCode, InsightSeverity
from apps.insights.messages import render_insight_text
from apps.insights.services import (
    DECIMAL_SUM_FIELD,
    ZERO_DECIMAL,
    DateRange,
    aggregate_total_base_amount,
    category_aggregates,
    transactions_for_period,
)
from apps.transactions.models import Transaction
from apps.transactions.services import convert_base_amount_to_display

INSIGHTS_GENERATOR_CODE = "rules_v1"
PERCENT_QUANTIZE_EXPONENT = Decimal("0.01")
MIN_MONTH_OVER_MONTH_PERCENT_CHANGE = Decimal("5.00")
WEEKEND_SHARE_THRESHOLD = Decimal("60.00")
WEEKDAY_SHARE_THRESHOLD = Decimal("75.00")
PATTERN_WINDOW_DAYS = 90
RECURRING_WINDOW_MONTHS = 6
RECURRING_MIN_ACTIVE_MONTHS = 3
MAX_INSIGHT_CARDS = 5


@dataclass(frozen=True, slots=True)
class InsightCard:
    code: str
    title: str
    message: str
    severity: str
    related_category_code: str | None = None
    related_category: Category | None = None
    period: DateRange | None = None
    metadata: dict[str, object] | None = None

    def as_payload(self) -> dict[str, object]:
        return {
            "code": self.code,
            "title": self.title,
            "message": self.message,
            "severity": self.severity,
            "related_category_code": self.related_category_code,
            "related_category": self.related_category,
            "period": self.period,
            "metadata": self.metadata or {},
        }


def build_generated_insights(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> dict[str, object]:
    resolved_language = language_code or DEFAULT_LANGUAGE_CODE
    insights = [
        insight
        for insight in (
            _build_month_over_month_insight(
                user=user,
                display_currency=display_currency,
                language_code=resolved_language,
            ),
            _build_top_category_current_month_insight(
                user=user,
                display_currency=display_currency,
                language_code=resolved_language,
            ),
            _build_weekday_pattern_insight(
                user=user,
                display_currency=display_currency,
                language_code=resolved_language,
            ),
            _build_most_frequent_category_insight(
                user=user,
                display_currency=display_currency,
                language_code=resolved_language,
            ),
            _build_recurring_category_signal_insight(
                user=user,
                display_currency=display_currency,
                language_code=resolved_language,
            ),
        )
        if insight is not None
    ]

    if not insights:
        insights = [
            _build_fallback_insight(
                user=user,
                language_code=resolved_language,
            )
        ]

    return {
        "generator": INSIGHTS_GENERATOR_CODE,
        "message_locale": resolved_language,
        "insights": [insight.as_payload() for insight in insights[:MAX_INSIGHT_CARDS]],
    }


def _build_top_category_current_month_insight(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> InsightCard | None:
    period = _current_month_to_date_period()
    category_rows = category_aggregates(user=user, period=period, limit=1)

    if not category_rows:
        return None

    current_month_total = aggregate_total_base_amount(
        transactions_for_period(user=user, period=period)
    )
    if current_month_total <= ZERO_DECIMAL:
        return None

    category_row = category_rows[0]
    category = category_row["category"]
    total_base_amount = category_row["total_base_amount"]
    total_display_amount = convert_base_amount_to_display(
        base_amount=total_base_amount,
        display_currency=display_currency,
    )
    share_percent = _percentage(total_base_amount, current_month_total)
    title, message = render_insight_text(
        code=InsightCode.TOP_CATEGORY_CURRENT_MONTH.value,
        language_code=language_code,
        category_label=_category_label(category=category, language_code=language_code),
        display_amount=_stringify_decimal(total_display_amount),
        display_currency=display_currency,
        share_percent=_stringify_decimal(share_percent),
    )
    return InsightCard(
        code=InsightCode.TOP_CATEGORY_CURRENT_MONTH.value,
        title=title,
        message=message,
        severity=InsightSeverity.INFO.value,
        related_category_code=category.code,
        related_category=category,
        period=period,
        metadata={
            "transaction_count": category_row["transaction_count"],
            "total_base_amount": _stringify_decimal(total_base_amount),
            "total_display_amount": _stringify_decimal(total_display_amount),
            "share_percent": _stringify_decimal(share_percent),
        },
    )


def _build_month_over_month_insight(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> InsightCard | None:
    today = timezone.localdate()
    current_period = _current_month_to_date_period(today=today)
    previous_period = _previous_month_same_day_period(today=today)

    current_total = aggregate_total_base_amount(
        transactions_for_period(user=user, period=current_period)
    )
    previous_total = aggregate_total_base_amount(
        transactions_for_period(user=user, period=previous_period)
    )
    if previous_total <= ZERO_DECIMAL:
        return None

    change_base_amount = current_total - previous_total
    if change_base_amount == ZERO_DECIMAL:
        return None

    change_percent = _percentage(abs(change_base_amount), previous_total)
    if change_percent < MIN_MONTH_OVER_MONTH_PERCENT_CHANGE:
        return None

    insight_code = (
        InsightCode.MONTH_OVER_MONTH_INCREASE
        if change_base_amount > ZERO_DECIMAL
        else InsightCode.MONTH_OVER_MONTH_DECREASE
    )
    severity = (
        InsightSeverity.WARNING.value
        if insight_code is InsightCode.MONTH_OVER_MONTH_INCREASE
        else InsightSeverity.POSITIVE.value
    )
    current_total_display = convert_base_amount_to_display(
        base_amount=current_total,
        display_currency=display_currency,
    )
    previous_total_display = convert_base_amount_to_display(
        base_amount=previous_total,
        display_currency=display_currency,
    )
    change_display_amount = convert_base_amount_to_display(
        base_amount=abs(change_base_amount),
        display_currency=display_currency,
    )
    title, message = render_insight_text(
        code=insight_code.value,
        language_code=language_code,
        change_percent=_stringify_decimal(change_percent),
    )
    return InsightCard(
        code=insight_code.value,
        title=title,
        message=message,
        severity=severity,
        period=current_period,
        metadata={
            "direction": "up" if change_base_amount > ZERO_DECIMAL else "down",
            "current_total_base_amount": _stringify_decimal(current_total),
            "current_total_display_amount": _stringify_decimal(current_total_display),
            "previous_total_base_amount": _stringify_decimal(previous_total),
            "previous_total_display_amount": _stringify_decimal(previous_total_display),
            "change_base_amount": _stringify_decimal(abs(change_base_amount)),
            "change_display_amount": _stringify_decimal(change_display_amount),
            "change_percent": _stringify_decimal(change_percent),
            "comparison_date_from": previous_period.date_from.isoformat(),
            "comparison_date_to": previous_period.date_to.isoformat(),
        },
    )


def _build_weekday_pattern_insight(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> InsightCard | None:
    period = _last_n_days_period(days=PATTERN_WINDOW_DAYS)
    rows = list(
        transactions_for_period(user=user, period=period).values_list(
            "transaction_date",
            "base_amount",
        )
    )
    if len(rows) < 4:
        return None

    weekend_total = ZERO_DECIMAL
    weekday_total = ZERO_DECIMAL
    for transaction_date, base_amount in rows:
        if transaction_date.isoweekday() >= 6:
            weekend_total += base_amount
        else:
            weekday_total += base_amount

    total_spent = weekend_total + weekday_total
    if total_spent <= ZERO_DECIMAL:
        return None

    weekend_share = _percentage(weekend_total, total_spent)
    weekday_share = _percentage(weekday_total, total_spent)
    if weekend_share >= WEEKEND_SHARE_THRESHOLD:
        insight_code = InsightCode.WEEKEND_SPENDING_PATTERN
        dominant_base_amount = weekend_total
        dominant_display_amount = convert_base_amount_to_display(
            base_amount=weekend_total,
            display_currency=display_currency,
        )
        share_percent = weekend_share
    elif weekday_share >= WEEKDAY_SHARE_THRESHOLD:
        insight_code = InsightCode.WEEKDAY_SPENDING_PATTERN
        dominant_base_amount = weekday_total
        dominant_display_amount = convert_base_amount_to_display(
            base_amount=weekday_total,
            display_currency=display_currency,
        )
        share_percent = weekday_share
    else:
        return None

    title, message = render_insight_text(
        code=insight_code.value,
        language_code=language_code,
        share_percent=_stringify_decimal(share_percent),
    )
    return InsightCard(
        code=insight_code.value,
        title=title,
        message=message,
        severity=InsightSeverity.INFO.value,
        period=period,
        metadata={
            "transaction_count": len(rows),
            "dominant_total_base_amount": _stringify_decimal(dominant_base_amount),
            "dominant_total_display_amount": _stringify_decimal(dominant_display_amount),
            "weekend_share_percent": _stringify_decimal(weekend_share),
            "weekday_share_percent": _stringify_decimal(weekday_share),
            "weekend_total_base_amount": _stringify_decimal(weekend_total),
            "weekday_total_base_amount": _stringify_decimal(weekday_total),
        },
    )


def _build_most_frequent_category_insight(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> InsightCard | None:
    period = _last_n_days_period(days=PATTERN_WINDOW_DAYS)
    filters = {
        "transactions__user": user,
        "transactions__transaction_date__range": (period.date_from, period.date_to),
        "transactions__is_deleted": False,
    }
    category = (
        Category.objects.filter(**filters)
        .annotate(
            transaction_count=Count("transactions"),
            total_base_amount=Coalesce(
                Sum("transactions__base_amount"),
                Value(ZERO_DECIMAL, output_field=DECIMAL_SUM_FIELD),
            ),
        )
        .order_by("-transaction_count", "-total_base_amount", "sort_order", "code")
        .first()
    )
    if category is None or category.transaction_count < 3:
        return None

    total_display_amount = convert_base_amount_to_display(
        base_amount=category.total_base_amount,
        display_currency=display_currency,
    )
    title, message = render_insight_text(
        code=InsightCode.MOST_FREQUENT_CATEGORY.value,
        language_code=language_code,
        category_label=_category_label(category=category, language_code=language_code),
        transaction_count=category.transaction_count,
    )
    return InsightCard(
        code=InsightCode.MOST_FREQUENT_CATEGORY.value,
        title=title,
        message=message,
        severity=InsightSeverity.INFO.value,
        related_category_code=category.code,
        related_category=category,
        period=period,
        metadata={
            "transaction_count": category.transaction_count,
            "total_base_amount": _stringify_decimal(category.total_base_amount),
            "total_display_amount": _stringify_decimal(total_display_amount),
        },
    )


def _build_recurring_category_signal_insight(
    *,
    user,
    display_currency: str,
    language_code: str,
) -> InsightCard | None:
    period = _last_n_months_period(months=RECURRING_WINDOW_MONTHS)
    recurring_row = (
        transactions_for_period(user=user, period=period)
        .annotate(transaction_month=TruncMonth("transaction_date"))
        .values("category__code")
        .annotate(
            active_months=Count("transaction_month", distinct=True),
            transaction_count=Count("id"),
            total_base_amount=Coalesce(
                Sum("base_amount"),
                Value(ZERO_DECIMAL, output_field=DECIMAL_SUM_FIELD),
            ),
        )
        .filter(active_months__gte=RECURRING_MIN_ACTIVE_MONTHS)
        .order_by("-active_months", "-transaction_count", "-total_base_amount", "category__code")
        .first()
    )
    if recurring_row is None:
        return None

    category = Category.objects.filter(
        code=recurring_row["category__code"], is_active=True,
    ).first()
    if category is None:
        return None

    total_display_amount = convert_base_amount_to_display(
        base_amount=recurring_row["total_base_amount"],
        display_currency=display_currency,
    )
    title, message = render_insight_text(
        code=InsightCode.RECURRING_CATEGORY_SIGNAL.value,
        language_code=language_code,
        category_label=_category_label(category=category, language_code=language_code),
        active_months=recurring_row["active_months"],
        window_months=RECURRING_WINDOW_MONTHS,
    )
    return InsightCard(
        code=InsightCode.RECURRING_CATEGORY_SIGNAL.value,
        title=title,
        message=message,
        severity=InsightSeverity.INFO.value,
        related_category_code=category.code,
        related_category=category,
        period=period,
        metadata={
            "active_months": recurring_row["active_months"],
            "window_months": RECURRING_WINDOW_MONTHS,
            "transaction_count": recurring_row["transaction_count"],
            "total_base_amount": _stringify_decimal(recurring_row["total_base_amount"]),
            "total_display_amount": _stringify_decimal(total_display_amount),
        },
    )


def _build_fallback_insight(*, user, language_code: str) -> InsightCard:
    transaction_count = Transaction.objects.filter(user=user, is_deleted=False).count()
    title, message = render_insight_text(
        code=InsightCode.NOT_ENOUGH_DATA.value,
        language_code=language_code,
    )
    return InsightCard(
        code=InsightCode.NOT_ENOUGH_DATA.value,
        title=title,
        message=message,
        severity=InsightSeverity.INFO.value,
        metadata={
            "transaction_count": transaction_count,
        },
    )


def _current_month_to_date_period(*, today: date | None = None) -> DateRange:
    resolved_today = today or timezone.localdate()
    return DateRange(
        kind="current_month_to_date",
        date_from=resolved_today.replace(day=1),
        date_to=resolved_today,
    )


def _previous_month_same_day_period(*, today: date) -> DateRange:
    previous_month_start = _shift_month(today.replace(day=1), months=-1)
    last_day = monthrange(previous_month_start.year, previous_month_start.month)[1]
    comparison_day = min(today.day, last_day)
    return DateRange(
        kind="previous_month_to_same_day",
        date_from=previous_month_start,
        date_to=previous_month_start.replace(day=comparison_day),
    )


def _last_n_days_period(*, days: int) -> DateRange:
    today = timezone.localdate()
    return DateRange(
        kind=f"last_{days}_days",
        date_from=today - timedelta(days=days - 1),
        date_to=today,
    )


def _last_n_months_period(*, months: int) -> DateRange:
    today = timezone.localdate()
    month_start = today.replace(day=1)
    period_start = _shift_month(month_start, months=-(months - 1))
    return DateRange(
        kind=f"last_{months}_months",
        date_from=period_start,
        date_to=today,
    )


def _shift_month(value: date, *, months: int) -> date:
    month_index = (value.year * 12) + value.month - 1 + months
    year = month_index // 12
    month = (month_index % 12) + 1
    day = min(value.day, monthrange(year, month)[1])
    return date(year, month, day)


def _percentage(part: Decimal, whole: Decimal) -> Decimal:
    if whole <= ZERO_DECIMAL:
        return ZERO_DECIMAL

    return ((part / whole) * Decimal("100")).quantize(
        PERCENT_QUANTIZE_EXPONENT,
        rounding=ROUND_HALF_UP,
    )


def _category_label(*, category: Category, language_code: str) -> str:
    definition = get_category_definition(category.code)
    if definition is None:
        return category.default_label

    return definition.label_for(language_code or DEFAULT_LANGUAGE_CODE)


def _stringify_decimal(value: Decimal) -> str:
    return str(value.quantize(PERCENT_QUANTIZE_EXPONENT, rounding=ROUND_HALF_UP))
