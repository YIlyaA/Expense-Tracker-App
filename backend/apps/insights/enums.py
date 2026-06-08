from __future__ import annotations

from enum import StrEnum


class InsightCode(StrEnum):
    MONTH_OVER_MONTH_INCREASE = "month_over_month_increase"
    MONTH_OVER_MONTH_DECREASE = "month_over_month_decrease"
    TOP_CATEGORY_CURRENT_MONTH = "top_category_current_month"
    WEEKEND_SPENDING_PATTERN = "weekend_spending_pattern"
    WEEKDAY_SPENDING_PATTERN = "weekday_spending_pattern"
    MOST_FREQUENT_CATEGORY = "most_frequent_category"
    RECURRING_CATEGORY_SIGNAL = "recurring_category_signal"
    NOT_ENOUGH_DATA = "not_enough_data"

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(member.value for member in cls)


class InsightSeverity(StrEnum):
    INFO = "info"
    POSITIVE = "positive"
    WARNING = "warning"

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(member.value for member in cls)
