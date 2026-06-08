from __future__ import annotations

from dataclasses import dataclass

from apps.common.constants import DEFAULT_LANGUAGE_CODE
from apps.insights.enums import InsightCode


@dataclass(frozen=True, slots=True)
class InsightTextTemplate:
    titles: dict[str, str]
    messages: dict[str, str]

    def render(self, *, language_code: str, **kwargs: object) -> tuple[str, str]:
        resolved_language = language_code if language_code in self.titles else DEFAULT_LANGUAGE_CODE
        return (
            self.titles[resolved_language].format(**kwargs),
            self.messages[resolved_language].format(**kwargs),
        )


INSIGHT_TEXT_TEMPLATES: dict[str, InsightTextTemplate] = {
    InsightCode.TOP_CATEGORY_CURRENT_MONTH.value: InsightTextTemplate(
        titles={
            "en": "Top category this month",
            "pl": "Glowna kategoria w tym miesiacu",
            "ru": "Главная категория в этом месяце",
        },
        messages={
            "en": (
                "{category_label} leads your spending this month at "
                "{display_amount} {display_currency}, or {share_percent}% of the total."
            ),
            "pl": (
                "{category_label} prowadzi w tym miesiacu z kwota "
                "{display_amount} {display_currency}, czyli {share_percent}% wszystkich wydatkow."
            ),
            "ru": (
                "{category_label} лидирует в этом месяце с суммой "
                "{display_amount} {display_currency}, это {share_percent}% всех расходов."
            ),
        },
    ),
    InsightCode.MONTH_OVER_MONTH_INCREASE.value: InsightTextTemplate(
        titles={
            "en": "Spending is up this month",
            "pl": "Wydatki rosna w tym miesiacu",
            "ru": "Расходы выросли в этом месяце",
        },
        messages={
            "en": "You spent {change_percent}% more than at the same point last month.",
            "pl": (
                "Wydatki sa o {change_percent}% wyzsze niz w tym samym momencie "
                "poprzedniego miesiaca."
            ),
            "ru": "Ваши расходы на {change_percent}% выше, чем в тот же момент прошлого месяца.",
        },
    ),
    InsightCode.MONTH_OVER_MONTH_DECREASE.value: InsightTextTemplate(
        titles={
            "en": "Spending is down this month",
            "pl": "Wydatki spadaja w tym miesiacu",
            "ru": "Расходы снизились в этом месяце",
        },
        messages={
            "en": "You spent {change_percent}% less than at the same point last month.",
            "pl": (
                "Wydatki sa o {change_percent}% nizsze niz w tym samym momencie "
                "poprzedniego miesiaca."
            ),
            "ru": "Ваши расходы на {change_percent}% ниже, чем в тот же момент прошлого месяца.",
        },
    ),
    InsightCode.WEEKEND_SPENDING_PATTERN.value: InsightTextTemplate(
        titles={
            "en": "Weekend spending stands out",
            "pl": "Weekendy wyrozniaja sie w wydatkach",
            "ru": "Расходы на выходных выделяются",
        },
        messages={
            "en": "{share_percent}% of your spending in the last 90 days happened on weekends.",
            "pl": "{share_percent}% Twoich wydatkow z ostatnich 90 dni przypadlo na weekendy.",
            "ru": "{share_percent}% ваших расходов за последние 90 дней пришлось на выходные.",
        },
    ),
    InsightCode.WEEKDAY_SPENDING_PATTERN.value: InsightTextTemplate(
        titles={
            "en": "Weekday spending stands out",
            "pl": "Dni robocze wyrozniaja sie w wydatkach",
            "ru": "Расходы в будни выделяются",
        },
        messages={
            "en": "{share_percent}% of your spending in the last 90 days happened on weekdays.",
            "pl": "{share_percent}% Twoich wydatkow z ostatnich 90 dni przypadlo na dni robocze.",
            "ru": "{share_percent}% ваших расходов за последние 90 дней пришлось на будни.",
        },
    ),
    InsightCode.MOST_FREQUENT_CATEGORY.value: InsightTextTemplate(
        titles={
            "en": "Most frequent category recently",
            "pl": "Najczestsza kategoria ostatnio",
            "ru": "Самая частая категория за последнее время",
        },
        messages={
            "en": (
                "{category_label} appears most often in your spending over "
                "the last 90 days ({transaction_count} transactions)."
            ),
            "pl": (
                "{category_label} pojawia sie najczesciej w Twoich wydatkach z "
                "ostatnich 90 dni ({transaction_count} transakcji)."
            ),
            "ru": (
                "{category_label} встречается чаще всего в ваших расходах за "
                "последние 90 дней ({transaction_count} транзакций)."
            ),
        },
    ),
    InsightCode.RECURRING_CATEGORY_SIGNAL.value: InsightTextTemplate(
        titles={
            "en": "Recurring expense signal",
            "pl": "Sygnał powtarzalnego wydatku",
            "ru": "Сигнал регулярного расхода",
        },
        messages={
            "en": (
                "{category_label} appeared in {active_months} of the last "
                "{window_months} months, which looks like a recurring expense pattern."
            ),
            "pl": (
                "{category_label} pojawia sie w {active_months} z ostatnich "
                "{window_months} miesiecy, co wyglada na staly wydatek."
            ),
            "ru": (
                "{category_label} встречается в {active_months} из последних "
                "{window_months} месяцев, это похоже на регулярный расход."
            ),
        },
    ),
    InsightCode.NOT_ENOUGH_DATA.value: InsightTextTemplate(
        titles={
            "en": "More history needed",
            "pl": "Potrzeba wiecej historii",
            "ru": "Нужно больше истории",
        },
        messages={
            "en": "Add a few more expenses to unlock stronger patterns and comparisons.",
            "pl": "Dodaj jeszcze kilka wydatkow, aby odblokowac wyrazniejsze wzorce i porownania.",
            "ru": (
                "Добавьте еще несколько расходов, чтобы появились более сильные "
                "паттерны и сравнения."
            ),
        },
    ),
}


def render_insight_text(*, code: str, language_code: str, **kwargs: object) -> tuple[str, str]:
    template = INSIGHT_TEXT_TEMPLATES[code]
    return template.render(language_code=language_code, **kwargs)
