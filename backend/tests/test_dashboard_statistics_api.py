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


def dashboard_url() -> str:
    return reverse("dashboard-summary", kwargs={"version": "v1"})


def statistics_url() -> str:
    return reverse("statistics-summary", kwargs={"version": "v1"})


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
        "apps.insights.services.timezone.localdate",
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


def test_dashboard_and_statistics_require_authentication(client):
    dashboard_response = client.get(dashboard_url())
    statistics_response = client.get(statistics_url())

    assert dashboard_response.status_code == 401
    assert statistics_response.status_code == 401


def test_dashboard_current_month_totals_use_owner_data_and_preferred_currency(
    client,
    monkeypatch,
):
    freeze_today(monkeypatch, date(2026, 3, 15))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    other_user = User.objects.create_user(email="other@example.com", password="ComplexPass12345")
    user.settings.preferred_currency = "USD"
    user.settings.save(update_fields=["preferred_currency"])
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 2),
        original_amount="10.00",
        original_currency="USD",
        description="Groceries",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 3),
        original_amount="20.00",
        original_currency="PLN",
        description="Bus",
    )
    create_transaction_for_user(
        user=user,
        category_code="health",
        transaction_date=date(2026, 2, 25),
        original_amount="99.00",
        original_currency="PLN",
        description="Older",
    )
    create_transaction_for_user(
        user=other_user,
        category_code="food",
        transaction_date=date(2026, 3, 4),
        original_amount="100.00",
        original_currency="PLN",
        description="Other user",
    )

    response = client.get(dashboard_url(), **auth_headers(access_token))
    payload = response.json()

    assert response.status_code == 200
    assert payload["currency_context"] == {
        "base_currency": "PLN",
        "display_currency": "USD",
        "conversion_source": "seed_default_v1",
    }
    assert payload["period"] == {
        "kind": "current_month",
        "date_from": "2026-03-01",
        "date_to": "2026-03-31",
    }
    assert payload["current_month_total"] == {
        "base_amount": "60.00",
        "display_amount": "15.00",
    }


def test_dashboard_recent_transactions_are_ordered_and_have_mobile_friendly_shape(
    client,
    monkeypatch,
):
    freeze_today(monkeypatch, date(2026, 3, 15))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    older = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 2),
        original_amount="20.00",
        description="Groceries",
    )
    middle = create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 3),
        original_amount="12.00",
        description="Taxi",
    )
    newest = create_transaction_for_user(
        user=user,
        category_code="health",
        transaction_date=date(2026, 3, 5),
        original_amount="30.00",
        description="Pharmacy",
    )

    response = client.get(dashboard_url(), **auth_headers(access_token))
    recent_transactions = response.json()["recent_transactions"]

    assert response.status_code == 200
    assert [item["id"] for item in recent_transactions] == [newest.id, middle.id, older.id]
    assert recent_transactions[0]["category_code"] == "health"
    assert recent_transactions[0]["category"]["code"] == "health"
    assert recent_transactions[0]["display_amount"] == "30.00"
    assert "created_at" in recent_transactions[0]


def test_dashboard_top_categories_are_aggregated_for_current_month(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 15))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 2),
        original_amount="25.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 4),
        original_amount="15.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 5),
        original_amount="30.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="health",
        transaction_date=date(2026, 2, 20),
        original_amount="99.00",
    )

    response = client.get(dashboard_url(), **auth_headers(access_token))
    top_categories = response.json()["top_categories"]

    assert response.status_code == 200
    assert top_categories == [
        {
            "category_code": "food",
            "category": {
                "code": "food",
                "default_label": "Food",
                "label": "Food",
                "icon_key": "utensils",
                "color": "#EF4444",
                "sort_order": 10,
                "is_active": True,
            },
            "transaction_count": 2,
            "total_base_amount": "40.00",
            "total_display_amount": "40.00",
        },
        {
            "category_code": "transport",
            "category": {
                "code": "transport",
                "default_label": "Transport",
                "label": "Transport",
                "icon_key": "bus",
                "color": "#3B82F6",
                "sort_order": 20,
                "is_active": True,
            },
            "transaction_count": 1,
            "total_base_amount": "30.00",
            "total_display_amount": "30.00",
        },
    ]


def test_statistics_support_custom_period_breakdown_monthly_totals_and_owner_isolation(
    client,
):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    other_user = User.objects.create_user(email="other@example.com", password="ComplexPass12345")
    user.settings.preferred_currency = "EUR"
    user.settings.save(update_fields=["preferred_currency"])
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 1, 10),
        original_amount="10.00",
        original_currency="USD",
    )
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 5),
        original_amount="20.00",
        original_currency="PLN",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 7),
        original_amount="10.00",
        original_currency="EUR",
    )
    create_transaction_for_user(
        user=other_user,
        category_code="food",
        transaction_date=date(2026, 3, 8),
        original_amount="999.00",
        original_currency="PLN",
    )

    response = client.get(
        statistics_url(),
        data={
            "date_from": "2026-01-01",
            "date_to": "2026-03-31",
        },
        **auth_headers(access_token),
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["currency_context"] == {
        "base_currency": "PLN",
        "display_currency": "EUR",
        "conversion_source": "seed_default_v1",
    }
    assert payload["period"] == {
        "kind": "custom",
        "date_from": "2026-01-01",
        "date_to": "2026-03-31",
    }
    assert payload["total_spent"] == {
        "base_amount": "103.00",
        "display_amount": "23.95",
    }
    assert payload["category_breakdown"] == [
        {
            "category_code": "food",
            "category": {
                "code": "food",
                "default_label": "Food",
                "label": "Food",
                "icon_key": "utensils",
                "color": "#EF4444",
                "sort_order": 10,
                "is_active": True,
            },
            "transaction_count": 2,
            "total_base_amount": "60.00",
            "total_display_amount": "13.95",
        },
        {
            "category_code": "transport",
            "category": {
                "code": "transport",
                "default_label": "Transport",
                "label": "Transport",
                "icon_key": "bus",
                "color": "#3B82F6",
                "sort_order": 20,
                "is_active": True,
            },
            "transaction_count": 1,
            "total_base_amount": "43.00",
            "total_display_amount": "10.00",
        },
    ]
    assert payload["monthly_totals"] == [
        {
            "month": "2026-01",
            "total_base_amount": "40.00",
            "total_display_amount": "9.30",
        },
        {
            "month": "2026-02",
            "total_base_amount": "0.00",
            "total_display_amount": "0.00",
        },
        {
            "month": "2026-03",
            "total_base_amount": "63.00",
            "total_display_amount": "14.65",
        },
    ]


def test_dashboard_and_statistics_return_empty_state_without_transactions(client, monkeypatch):
    freeze_today(monkeypatch, date(2026, 3, 15))
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    dashboard_response = client.get(dashboard_url(), **auth_headers(access_token))
    statistics_response = client.get(statistics_url(), **auth_headers(access_token))

    assert dashboard_response.status_code == 200
    assert dashboard_response.json()["current_month_total"] == {
        "base_amount": "0.00",
        "display_amount": "0.00",
    }
    assert dashboard_response.json()["recent_transactions"] == []
    assert dashboard_response.json()["top_categories"] == []

    assert statistics_response.status_code == 200
    assert statistics_response.json()["total_spent"] == {
        "base_amount": "0.00",
        "display_amount": "0.00",
    }
    assert statistics_response.json()["category_breakdown"] == []
    assert statistics_response.json()["monthly_totals"] == [
        {
            "month": "2026-03",
            "total_base_amount": "0.00",
            "total_display_amount": "0.00",
        }
    ]


def test_statistics_reject_partial_date_range(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.get(
        statistics_url(),
        data={"date_from": "2026-03-01"},
        **auth_headers(access_token),
    )

    assert response.status_code == 400
    assert response.json() == {
        "non_field_errors": ["date_from and date_to must be provided together."]
    }
