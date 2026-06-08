from datetime import date

import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.categories.models import Category
from apps.transactions.models import Transaction
from apps.transactions.services import calculate_base_amount

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def insights_url() -> str:
    return reverse("generated-insights", kwargs={"version": "v1"})


def access_token_for(client, *, email: str, password: str) -> str:
    response = client.post(
        login_url(),
        data={
            "email": email,
            "password": password,
        },
        content_type="application/json",
    )

    return response.json()["tokens"]["access"]


def freeze_today(monkeypatch, frozen_date: date) -> None:
    monkeypatch.setattr(
        "apps.insights.generation.timezone.localdate",
        lambda: frozen_date,
    )


def create_transaction_for_user(
    *,
    user,
    category_code: str,
    transaction_date: date,
    original_amount: str,
    original_currency: str = "PLN",
    description: str = "",
) -> Transaction:
    category = Category.objects.get(code=category_code)
    original_amount_decimal = Transaction.original_amount.field.to_python(original_amount)
    return Transaction.objects.create(
        user=user,
        category=category,
        description=description,
        original_amount=original_amount_decimal,
        original_currency=original_currency,
        base_amount=calculate_base_amount(
            original_amount=original_amount_decimal,
            original_currency=original_currency,
        ),
        base_currency="PLN",
        transaction_date=transaction_date,
    )


def test_insights_require_authentication(client):
    response = client.get(insights_url())

    assert response.status_code == 401


def test_insights_return_fallback_card_without_transactions(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 20))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.get(insights_url(), **auth_headers(access_token))
    payload = response.json()

    assert response.status_code == 200
    assert payload["generator"] == "rules_v1"
    assert payload["message_locale"] == "en"
    assert payload["currency_context"] == {
        "base_currency": "PLN",
        "display_currency": "PLN",
        "conversion_source": "identity",
    }
    assert payload["insights"] == [
        {
            "code": "not_enough_data",
            "title": "More history needed",
            "message": "Add a few more expenses to unlock stronger patterns and comparisons.",
            "severity": "info",
            "related_category_code": None,
            "related_category": None,
            "period": None,
            "metadata": {"transaction_count": 0},
        }
    ]


def test_insights_generate_expected_cards_for_deterministic_history(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 20))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    user.settings.preferred_currency = "USD"
    user.settings.save(update_fields=["preferred_currency"])
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    create_transaction_for_user(
        user=user,
        category_code="subscriptions_education",
        transaction_date=date(2026, 1, 10),
        original_amount="30.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="subscriptions_education",
        transaction_date=date(2026, 2, 7),
        original_amount="30.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 2, 18),
        original_amount="20.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 2, 20),
        original_amount="20.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="subscriptions_education",
        transaction_date=date(2026, 3, 7),
        original_amount="30.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 14),
        original_amount="60.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 15),
        original_amount="40.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 16),
        original_amount="10.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 18),
        original_amount="10.00",
    )

    response = client.get(insights_url(), **auth_headers(access_token))
    payload = response.json()

    assert response.status_code == 200
    assert payload["generator"] == "rules_v1"
    assert payload["message_locale"] == "en"
    assert payload["currency_context"] == {
        "base_currency": "PLN",
        "display_currency": "USD",
        "conversion_source": "seed_default_v1",
    }
    assert [item["code"] for item in payload["insights"]] == [
        "month_over_month_increase",
        "top_category_current_month",
        "weekend_spending_pattern",
        "most_frequent_category",
        "recurring_category_signal",
    ]
    assert payload["insights"][0] == {
        "code": "month_over_month_increase",
        "title": "Spending is up this month",
        "message": "You spent 114.29% more than at the same point last month.",
        "severity": "warning",
        "related_category_code": None,
        "related_category": None,
        "period": {
            "kind": "current_month_to_date",
            "date_from": "2026-03-01",
            "date_to": "2026-03-20",
        },
        "metadata": {
            "direction": "up",
            "current_total_base_amount": "150.00",
            "current_total_display_amount": "37.50",
            "previous_total_base_amount": "70.00",
            "previous_total_display_amount": "17.50",
            "change_base_amount": "80.00",
            "change_display_amount": "20.00",
            "change_percent": "114.29",
            "comparison_date_from": "2026-02-01",
            "comparison_date_to": "2026-02-20",
        },
    }
    assert payload["insights"][1] == {
        "code": "top_category_current_month",
        "title": "Top category this month",
        "message": "Food leads your spending this month at 27.50 USD, or 73.33% of the total.",
        "severity": "info",
        "related_category_code": "food",
        "related_category": {
            "code": "food",
            "default_label": "Food",
            "label": "Food",
            "icon_key": "utensils",
            "color": "#EF4444",
            "sort_order": 10,
            "is_active": True,
        },
        "period": {
            "kind": "current_month_to_date",
            "date_from": "2026-03-01",
            "date_to": "2026-03-20",
        },
        "metadata": {
            "transaction_count": 3,
            "total_base_amount": "110.00",
            "total_display_amount": "27.50",
            "share_percent": "73.33",
        },
    }
    assert payload["insights"][2] == {
        "code": "weekend_spending_pattern",
        "title": "Weekend spending stands out",
        "message": "76.00% of your spending in the last 90 days happened on weekends.",
        "severity": "info",
        "related_category_code": None,
        "related_category": None,
        "period": {
            "kind": "last_90_days",
            "date_from": "2025-12-21",
            "date_to": "2026-03-20",
        },
        "metadata": {
            "transaction_count": 9,
            "dominant_total_base_amount": "190.00",
            "dominant_total_display_amount": "47.50",
            "weekend_share_percent": "76.00",
            "weekday_share_percent": "24.00",
            "weekend_total_base_amount": "190.00",
            "weekday_total_base_amount": "60.00",
        },
    }
    assert payload["insights"][3] == {
        "code": "most_frequent_category",
        "title": "Most frequent category recently",
        "message": (
            "Food appears most often in your spending over the last 90 days "
            "(4 transactions)."
        ),
        "severity": "info",
        "related_category_code": "food",
        "related_category": {
            "code": "food",
            "default_label": "Food",
            "label": "Food",
            "icon_key": "utensils",
            "color": "#EF4444",
            "sort_order": 10,
            "is_active": True,
        },
        "period": {
            "kind": "last_90_days",
            "date_from": "2025-12-21",
            "date_to": "2026-03-20",
        },
        "metadata": {
            "transaction_count": 4,
            "total_base_amount": "130.00",
            "total_display_amount": "32.50",
        },
    }
    assert payload["insights"][4] == {
        "code": "recurring_category_signal",
        "title": "Recurring expense signal",
        "message": (
            "Subscriptions / Education appeared in 3 of the last 6 months, "
            "which looks like a recurring expense pattern."
        ),
        "severity": "info",
        "related_category_code": "subscriptions_education",
        "related_category": {
            "code": "subscriptions_education",
            "default_label": "Subscriptions / Education",
            "label": "Subscriptions / Education",
            "icon_key": "book-open",
            "color": "#06B6D4",
            "sort_order": 90,
            "is_active": True,
        },
        "period": {
            "kind": "last_6_months",
            "date_from": "2025-10-01",
            "date_to": "2026-03-20",
        },
        "metadata": {
            "active_months": 3,
            "window_months": 6,
            "transaction_count": 3,
            "total_base_amount": "90.00",
            "total_display_amount": "22.50",
        },
    }


def test_insights_are_owner_scoped(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 20))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    other_user = User.objects.create_user(email="other@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        original_amount="25.00",
    )
    create_transaction_for_user(
        user=other_user,
        category_code="transport",
        transaction_date=date(2026, 2, 10),
        original_amount="100.00",
    )
    create_transaction_for_user(
        user=other_user,
        category_code="transport",
        transaction_date=date(2026, 3, 10),
        original_amount="300.00",
    )

    response = client.get(insights_url(), **auth_headers(access_token))
    payload = response.json()

    assert response.status_code == 200
    assert [item["code"] for item in payload["insights"]] == ["top_category_current_month"]
    assert payload["insights"][0]["related_category_code"] == "food"
    assert payload["insights"][0]["metadata"]["total_base_amount"] == "25.00"


def test_insights_localize_messages_to_preferred_language(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 20))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    user.settings.preferred_language = "pl"
    user.settings.save(update_fields=["preferred_language"])
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        original_amount="40.00",
    )

    response = client.get(insights_url(), **auth_headers(access_token))
    first_insight = response.json()["insights"][0]

    assert response.status_code == 200
    assert response.json()["message_locale"] == "pl"
    assert first_insight["code"] == "top_category_current_month"
    assert first_insight["title"] == "Glowna kategoria w tym miesiacu"
    assert (
        first_insight["message"]
        == "Jedzenie prowadzi w tym miesiacu z kwota 40.00 PLN, czyli 100.00% wszystkich wydatkow."
    )
