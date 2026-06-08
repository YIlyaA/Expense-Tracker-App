from __future__ import annotations

from dataclasses import dataclass
from typing import Final

from apps.common.enums import AppLanguage, ExpenseCategoryCode


@dataclass(frozen=True, slots=True)
class DefaultCategoryDefinition:
    code: str
    default_label: str
    icon_key: str
    color: str
    sort_order: int
    localized_labels: dict[str, str]
    is_active: bool = True

    def label_for(self, language_code: str) -> str:
        return self.localized_labels.get(language_code, self.default_label)


DEFAULT_CATEGORY_DEFINITIONS: Final[tuple[DefaultCategoryDefinition, ...]] = (
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.FOOD.value,
        default_label="Food",
        icon_key="utensils",
        color="#EF4444",
        sort_order=10,
        localized_labels={
            AppLanguage.EN.value: "Food",
            AppLanguage.PL.value: "Jedzenie",
            AppLanguage.RU.value: "Еда",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.TRANSPORT.value,
        default_label="Transport",
        icon_key="bus",
        color="#3B82F6",
        sort_order=20,
        localized_labels={
            AppLanguage.EN.value: "Transport",
            AppLanguage.PL.value: "Transport",
            AppLanguage.RU.value: "Транспорт",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.PHONE.value,
        default_label="Phone",
        icon_key="smartphone",
        color="#8B5CF6",
        sort_order=30,
        localized_labels={
            AppLanguage.EN.value: "Phone",
            AppLanguage.PL.value: "Telefon",
            AppLanguage.RU.value: "Телефон",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.SPORT.value,
        default_label="Sport",
        icon_key="dumbbell",
        color="#10B981",
        sort_order=40,
        localized_labels={
            AppLanguage.EN.value: "Sport",
            AppLanguage.PL.value: "Sport",
            AppLanguage.RU.value: "Спорт",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.HOUSEHOLD.value,
        default_label="Household",
        icon_key="home",
        color="#F59E0B",
        sort_order=50,
        localized_labels={
            AppLanguage.EN.value: "Household",
            AppLanguage.PL.value: "Gospodarstwo domowe",
            AppLanguage.RU.value: "Быт",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.HEALTH.value,
        default_label="Health",
        icon_key="heart-pulse",
        color="#EC4899",
        sort_order=60,
        localized_labels={
            AppLanguage.EN.value: "Health",
            AppLanguage.PL.value: "Zdrowie",
            AppLanguage.RU.value: "Здоровье",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.DOCUMENTS.value,
        default_label="Documents",
        icon_key="file-text",
        color="#64748B",
        sort_order=70,
        localized_labels={
            AppLanguage.EN.value: "Documents",
            AppLanguage.PL.value: "Dokumenty",
            AppLanguage.RU.value: "Документы",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.CLOTHES_ITEMS.value,
        default_label="Clothes / Items",
        icon_key="shopping-bag",
        color="#F97316",
        sort_order=80,
        localized_labels={
            AppLanguage.EN.value: "Clothes / Items",
            AppLanguage.PL.value: "Ubrania / rzeczy",
            AppLanguage.RU.value: "Одежда / вещи",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.SUBSCRIPTIONS_EDUCATION.value,
        default_label="Subscriptions / Education",
        icon_key="book-open",
        color="#06B6D4",
        sort_order=90,
        localized_labels={
            AppLanguage.EN.value: "Subscriptions / Education",
            AppLanguage.PL.value: "Subskrypcje / edukacja",
            AppLanguage.RU.value: "Подписки / обучение",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.TOP_UPS.value,
        default_label="Top-ups",
        icon_key="wallet",
        color="#84CC16",
        sort_order=100,
        localized_labels={
            AppLanguage.EN.value: "Top-ups",
            AppLanguage.PL.value: "Doładowania",
            AppLanguage.RU.value: "Пополнения",
        },
    ),
    DefaultCategoryDefinition(
        code=ExpenseCategoryCode.OTHER.value,
        default_label="Other",
        icon_key="circle-help",
        color="#6B7280",
        sort_order=110,
        localized_labels={
            AppLanguage.EN.value: "Other",
            AppLanguage.PL.value: "Inne",
            AppLanguage.RU.value: "Другое",
        },
    ),
)

DEFAULT_CATEGORY_CODES: Final[tuple[str, ...]] = tuple(
    definition.code for definition in DEFAULT_CATEGORY_DEFINITIONS
)

DEFAULT_CATEGORY_DEFINITIONS_BY_CODE: Final[dict[str, DefaultCategoryDefinition]] = {
    definition.code: definition for definition in DEFAULT_CATEGORY_DEFINITIONS
}


def get_category_definition(code: str) -> DefaultCategoryDefinition | None:
    return DEFAULT_CATEGORY_DEFINITIONS_BY_CODE.get(code)
