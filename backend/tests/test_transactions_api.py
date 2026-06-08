from datetime import date

import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone

from apps.categories.models import Category
from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.transactions.models import Transaction

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def transactions_url() -> str:
    return reverse("transactions-list", kwargs={"version": "v1"})


def transaction_detail_url(transaction_id: int) -> str:
    return reverse(
        "transactions-detail",
        kwargs={"version": "v1", "pk": transaction_id},
    )


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


def create_transaction_for_user(
    *,
    user,
    category_code: str,
    transaction_date: date,
    amount: str,
) -> Transaction:
    category = Category.objects.get(code=category_code)
    return Transaction.objects.create(
        user=user,
        category=category,
        description=f"{category_code} expense",
        original_amount=amount,
        original_currency="PLN",
        base_amount=amount,
        base_currency=SYSTEM_BASE_CURRENCY_CODE,
        transaction_date=transaction_date,
    )


def test_transaction_creation_success(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        transactions_url(),
        data={
            "category_code": "food",
            "description": "Lunch",
            "original_amount": "12.50",
            "original_currency": "USD",
            "transaction_date": "2026-03-10",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 201
    payload = response.json()

    assert payload["description"] == "Lunch"
    assert payload["category_code"] == "food"
    assert payload["original_amount"] == "12.50"
    assert payload["original_currency"] == "USD"
    assert payload["base_amount"] == "50.00"
    assert payload["base_currency"] == SYSTEM_BASE_CURRENCY_CODE
    assert payload["display_amount"] == "50.00"
    assert payload["display_currency"] == "PLN"
    assert payload["category"]["code"] == "food"
    assert payload["category"]["label"] == "Food"


def test_transaction_creation_rejects_non_positive_amount(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        transactions_url(),
        data={
            "category_code": "food",
            "description": "Lunch",
            "original_amount": "0.00",
            "original_currency": "PLN",
            "transaction_date": "2026-03-10",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 400
    assert response.json() == {"original_amount": ["Amount must be greater than zero."]}


def test_transaction_creation_rejects_invalid_currency(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        transactions_url(),
        data={
            "category_code": "food",
            "description": "Lunch",
            "original_amount": "12.50",
            "original_currency": "GBP",
            "transaction_date": "2026-03-10",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 400
    assert response.json() == {
        "original_currency": ['"GBP" is not a valid choice.']
    }


def test_transaction_creation_rejects_inactive_category(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    Category.objects.filter(code="other").update(is_active=False)

    response = client.post(
        transactions_url(),
        data={
            "category_code": "other",
            "description": "Misc",
            "original_amount": "10.00",
            "original_currency": "PLN",
            "transaction_date": "2026-03-10",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 400
    assert response.json() == {"category_code": ["Category must exist and be active."]}


def test_transaction_list_only_returns_owner_transactions(client):
    owner = User.objects.create_user(email="owner@example.com", password="ComplexPass12345")
    stranger = User.objects.create_user(email="stranger@example.com", password="ComplexPass12345")
    owner_access_token = access_token_for(client, email=owner.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=owner,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="12.00",
    )
    create_transaction_for_user(
        user=stranger,
        category_code="transport",
        transaction_date=date(2026, 3, 11),
        amount="8.00",
    )

    response = client.get(transactions_url(), **auth_headers(owner_access_token))
    payload = response.json()

    assert response.status_code == 200
    assert payload["count"] == 1
    assert len(payload["results"]) == 1
    assert payload["results"][0]["category_code"] == "food"
    assert payload["results"][0]["display_amount"] == "12.00"
    assert payload["results"][0]["display_currency"] == "PLN"
    assert payload["results"][0]["category"]["code"] == "food"


def test_transaction_detail_update_delete_are_owner_scoped(client):
    owner = User.objects.create_user(email="owner@example.com", password="ComplexPass12345")
    stranger = User.objects.create_user(email="stranger@example.com", password="ComplexPass12345")
    stranger_access_token = access_token_for(
        client,
        email=stranger.email,
        password="ComplexPass12345",
    )
    transaction = create_transaction_for_user(
        user=owner,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="12.00",
    )
    detail_url = transaction_detail_url(transaction.id)

    retrieve_response = client.get(detail_url, **auth_headers(stranger_access_token))
    patch_response = client.patch(
        detail_url,
        data={"description": "Updated"},
        content_type="application/json",
        **auth_headers(stranger_access_token),
    )
    delete_response = client.delete(detail_url, **auth_headers(stranger_access_token))

    assert retrieve_response.status_code == 404
    assert patch_response.status_code == 404
    assert delete_response.status_code == 404
    assert Transaction.objects.filter(id=transaction.id).exists()


def test_transaction_list_is_ordered_by_most_recent_first(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 8),
        amount="8.00",
    )
    newest = create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="health",
        transaction_date=date(2026, 3, 9),
        amount="20.00",
    )

    response = client.get(transactions_url(), **auth_headers(access_token))
    result_ids = [item["id"] for item in response.json()["results"]]

    assert response.status_code == 200
    assert result_ids[0] == newest.id


def test_transaction_list_supports_category_and_date_filters(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 8),
        amount="8.00",
    )
    target = create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )
    create_transaction_for_user(
        user=user,
        category_code="transport",
        transaction_date=date(2026, 2, 20),
        amount="15.00",
    )

    response = client.get(
        transactions_url(),
        data={
            "category": "TRANSPORT",
            "date_from": "2026-03-01",
            "date_to": "2026-03-31",
        },
        **auth_headers(access_token),
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["count"] == 1
    assert payload["results"][0]["id"] == target.id
    assert payload["results"][0]["category_code"] == "transport"


def test_transaction_response_includes_nested_category_metadata(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    transaction = create_transaction_for_user(
        user=user,
        category_code="subscriptions_education",
        transaction_date=date(2026, 3, 10),
        amount="19.99",
    )

    response = client.get(transaction_detail_url(transaction.id), **auth_headers(access_token))
    payload = response.json()

    assert response.status_code == 200
    assert payload["category_code"] == "subscriptions_education"
    assert payload["display_amount"] == "19.99"
    assert payload["display_currency"] == "PLN"
    assert payload["category"] == {
        "code": "subscriptions_education",
        "default_label": "Subscriptions / Education",
        "label": "Subscriptions / Education",
        "icon_key": "book-open",
        "color": "#06B6D4",
        "sort_order": 90,
        "is_active": True,
    }


def test_transaction_update_recalculates_base_amount(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    transaction = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )

    response = client.patch(
        transaction_detail_url(transaction.id),
        data={
            "original_amount": "15.00",
            "original_currency": "EUR",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json()["base_amount"] == "64.50"
    assert response.json()["base_currency"] == SYSTEM_BASE_CURRENCY_CODE
    assert response.json()["display_amount"] == "64.50"
    assert response.json()["display_currency"] == "PLN"


def test_owner_can_delete_transaction(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    transaction = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )

    response = client.delete(transaction_detail_url(transaction.id), **auth_headers(access_token))

    assert response.status_code == 204
    transaction.refresh_from_db()
    assert transaction.is_deleted is True
    assert transaction.deleted_at is not None


def test_soft_deleted_transactions_excluded_from_list(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    tx = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )
    tx.is_deleted = True
    tx.deleted_at = timezone.now()
    tx.save()

    response = client.get(transactions_url(), **auth_headers(access_token))

    assert response.status_code == 200
    assert response.json()["count"] == 0


def test_soft_deleted_transactions_excluded_from_detail(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    tx = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="10.00",
    )
    tx.is_deleted = True
    tx.deleted_at = timezone.now()
    tx.save()

    response = client.get(transaction_detail_url(tx.id), **auth_headers(access_token))

    assert response.status_code == 404
