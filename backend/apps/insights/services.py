from __future__ import annotations

from calendar import monthrange
from dataclasses import dataclass
from datetime import date
from decimal import Decimal

from django.db.models import Count, DecimalField, Q, Sum, Value
from django.db.models.functions import Coalesce, TruncMonth
from django.utils import timezone

from apps.categories.models import Category
from apps.transactions.models import Transaction

ZERO_DECIMAL = Decimal("0.00")
DECIMAL_SUM_FIELD = DecimalField(max_digits=12, decimal_places=2)


@dataclass(frozen=True, slots=True)
class DateRange:
    kind: str
    date_from: date
    date_to: date


def month_period_for(*, anchor_date: date, kind: str) -> DateRange:
    last_day = monthrange(anchor_date.year, anchor_date.month)[1]
    return DateRange(
        kind=kind,
        date_from=anchor_date.replace(day=1),
        date_to=anchor_date.replace(day=last_day),
    )


def resolve_period(*, date_from: date | None = None, date_to: date | None = None) -> DateRange:
    if date_from is None and date_to is None:
        return month_period_for(anchor_date=timezone.localdate(), kind="current_month")

    if date_from is None or date_to is None:
        raise ValueError("date_from and date_to must be provided together.")

    return DateRange(kind="custom", date_from=date_from, date_to=date_to)


def build_dashboard_data(*, user, recent_limit: int = 5) -> dict[str, object]:
    period = resolve_period()
    current_month_queryset = transactions_for_period(user=user, period=period)

    return {
        "period": serialize_period(period),
        "current_month_total": {
            "base_amount": aggregate_total_base_amount(current_month_queryset),
        },
        "recent_transactions": list(recent_transactions(user=user, limit=recent_limit)),
        "top_categories": category_aggregates(user=user, period=period, limit=5),
    }


def build_statistics_data(*, user, period: DateRange) -> dict[str, object]:
    queryset = transactions_for_period(user=user, period=period)

    return {
        "period": serialize_period(period),
        "total_spent": {
            "base_amount": aggregate_total_base_amount(queryset),
        },
        "category_breakdown": category_aggregates(user=user, period=period),
        "monthly_totals": monthly_totals(user=user, period=period),
    }


def transactions_for_period(*, user, period: DateRange):
    return Transaction.objects.filter(
        user=user,
        transaction_date__range=(period.date_from, period.date_to),
        is_deleted=False,
    )


def recent_transactions(*, user, limit: int):
    return (
        Transaction.objects.filter(user=user, is_deleted=False)
        .select_related("category")
        .order_by("-transaction_date", "-created_at", "-id")[:limit]
    )


def aggregate_total_base_amount(queryset) -> Decimal:
    return queryset.aggregate(
        total_base_amount=Coalesce(
            Sum("base_amount"),
            Value(ZERO_DECIMAL, output_field=DECIMAL_SUM_FIELD),
        )
    )["total_base_amount"]


def category_aggregates(
    *,
    user,
    period: DateRange,
    limit: int | None = None,
) -> list[dict[str, object]]:
    filters = Q(
        transactions__user=user,
        transactions__transaction_date__range=(period.date_from, period.date_to),
        transactions__is_deleted=False,
    )
    categories = (
        Category.objects.filter(filters)
        .annotate(
            total_base_amount=Coalesce(
                Sum("transactions__base_amount", filter=filters),
                Value(ZERO_DECIMAL, output_field=DECIMAL_SUM_FIELD),
            ),
            transaction_count=Count("transactions", filter=filters),
        )
        .order_by("-total_base_amount", "sort_order", "code")
    )

    if limit is not None:
        categories = categories[:limit]

    return [
        {
            "category": category,
            "transaction_count": category.transaction_count,
            "total_base_amount": category.total_base_amount,
        }
        for category in categories
    ]


def monthly_totals(*, user, period: DateRange) -> list[dict[str, object]]:
    queryset = transactions_for_period(user=user, period=period)
    monthly_rows = queryset.annotate(month=TruncMonth("transaction_date")).values("month").annotate(
        total_base_amount=Coalesce(
            Sum("base_amount"),
            Value(ZERO_DECIMAL, output_field=DECIMAL_SUM_FIELD),
        )
    )
    monthly_totals_map = {
        _month_key(_coerce_to_date(row["month"])): row["total_base_amount"] for row in monthly_rows
    }

    return [
        {
            "month": _month_key(month_start),
            "total_base_amount": monthly_totals_map.get(_month_key(month_start), ZERO_DECIMAL),
        }
        for month_start in _month_starts(period.date_from, period.date_to)
    ]


def _month_starts(date_from: date, date_to: date) -> list[date]:
    current = date(date_from.year, date_from.month, 1)
    end = date(date_to.year, date_to.month, 1)
    values: list[date] = []

    while current <= end:
        values.append(current)
        if current.month == 12:
            current = date(current.year + 1, 1, 1)
        else:
            current = date(current.year, current.month + 1, 1)

    return values


def serialize_period(period: DateRange) -> dict[str, object]:
    return {
        "kind": period.kind,
        "date_from": period.date_from,
        "date_to": period.date_to,
    }


def _month_key(month_start: date) -> str:
    return month_start.strftime("%Y-%m")


def _coerce_to_date(value) -> date:
    if isinstance(value, date):
        return value

    return value.date()
