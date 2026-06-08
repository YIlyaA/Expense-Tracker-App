from __future__ import annotations

from enum import StrEnum

from django.utils.functional import Promise
from django.utils.translation import gettext_lazy as _

type ChoiceLabel = str | Promise


class ChoiceEnum(StrEnum):
    @classmethod
    def choices(cls) -> tuple[tuple[str, ChoiceLabel], ...]:
        return tuple((member.value, member.label) for member in cls)

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(member.value for member in cls)

    @property
    def label(self) -> ChoiceLabel:
        raise NotImplementedError


class AppLanguage(ChoiceEnum):
    EN = "en"
    PL = "pl"
    RU = "ru"

    @property
    def label(self) -> ChoiceLabel:
        match self:
            case AppLanguage.EN:
                return _("English")
            case AppLanguage.PL:
                return _("Polish")
            case AppLanguage.RU:
                return _("Russian")

        raise AssertionError(f"Unhandled app language: {self}")


class CurrencyCode(ChoiceEnum):
    PLN = "PLN"
    USD = "USD"
    EUR = "EUR"

    @property
    def label(self) -> ChoiceLabel:
        match self:
            case CurrencyCode.PLN:
                return _("Polish zloty")
            case CurrencyCode.USD:
                return _("US dollar")
            case CurrencyCode.EUR:
                return _("Euro")

        raise AssertionError(f"Unhandled currency code: {self}")


class ExpenseCategoryCode(ChoiceEnum):
    FOOD = "food"
    TRANSPORT = "transport"
    PHONE = "phone"
    SPORT = "sport"
    HOUSEHOLD = "household"
    HEALTH = "health"
    DOCUMENTS = "documents"
    CLOTHES_ITEMS = "clothes_items"
    SUBSCRIPTIONS_EDUCATION = "subscriptions_education"
    TOP_UPS = "top_ups"
    OTHER = "other"

    @property
    def label(self) -> ChoiceLabel:
        match self:
            case ExpenseCategoryCode.FOOD:
                return _("Food")
            case ExpenseCategoryCode.TRANSPORT:
                return _("Transport")
            case ExpenseCategoryCode.PHONE:
                return _("Phone")
            case ExpenseCategoryCode.SPORT:
                return _("Sport")
            case ExpenseCategoryCode.HOUSEHOLD:
                return _("Household")
            case ExpenseCategoryCode.HEALTH:
                return _("Health")
            case ExpenseCategoryCode.DOCUMENTS:
                return _("Documents")
            case ExpenseCategoryCode.CLOTHES_ITEMS:
                return _("Clothes / Items")
            case ExpenseCategoryCode.SUBSCRIPTIONS_EDUCATION:
                return _("Subscriptions / Education")
            case ExpenseCategoryCode.TOP_UPS:
                return _("Top-ups")
            case ExpenseCategoryCode.OTHER:
                return _("Other")

        raise AssertionError(f"Unhandled expense category code: {self}")
