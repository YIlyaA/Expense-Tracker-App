import uuid
from datetime import date, timedelta
from decimal import Decimal

import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone

from apps.categories.models import Category
from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.preferences.models import UserSettings
from apps.transactions.models import Transaction

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {"HTTP_AUTHORIZATION": f"Bearer {access_token}"}


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def sync_pull_url() -> str:
    return reverse("sync-pull", kwargs={"version": "v1"})


def sync_push_url() -> str:
    return reverse("sync-push", kwargs={"version": "v1"})


def access_token_for(client, *, email: str, password: str) -> str:
    response = client.post(
        login_url(),
        data={"email": email, "password": password},
        content_type="application/json",
    )
    return response.json()["tokens"]["access"]


def create_user(email="sync@example.com", password="ComplexPass12345"):
    return User.objects.create_user(email=email, password=password)


def create_transaction(*, user, category_code="food", amount="25.00", tx_date=None):
    category = Category.objects.get(code=category_code)
    return Transaction.objects.create(
        user=user,
        category=category,
        description=f"{category_code} expense",
        original_amount=Decimal(amount),
        original_currency="PLN",
        base_amount=Decimal(amount),
        base_currency=SYSTEM_BASE_CURRENCY_CODE,
        transaction_date=tx_date or date(2026, 3, 15),
    )




def test_pull_requires_auth(client):
    response = client.get(sync_pull_url())
    assert response.status_code == 401


def test_push_requires_auth(client):
    response = client.post(sync_push_url(), data={}, content_type="application/json")
    assert response.status_code == 401




def test_full_pull_returns_all_data(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)

    response = client.get(sync_pull_url(), **auth_headers(token))

    assert response.status_code == 200
    data = response.json()

    assert "server_timestamp" in data
    assert len(data["categories"]) > 0
    assert len(data["transactions"]["upserted"]) == 1
    assert data["transactions"]["upserted"][0]["id"] == tx.id
    assert data["transactions"]["deleted_ids"] == []
    assert data["settings"] is not None
    assert "preferred_language" in data["settings"]


def test_full_pull_excludes_soft_deleted(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)
    tx.is_deleted = True
    tx.deleted_at = timezone.now()
    tx.save()

    response = client.get(sync_pull_url(), **auth_headers(token))

    data = response.json()
    assert len(data["transactions"]["upserted"]) == 0
    assert data["transactions"]["deleted_ids"] == []




def test_incremental_pull_returns_only_changes(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")

    old_tx = create_transaction(user=user, amount="10.00")
    since = timezone.now()

    new_tx = create_transaction(user=user, amount="20.00")

    response = client.get(
        sync_pull_url() + f"?since={since.isoformat()}",
        **auth_headers(token),
    )

    assert response.status_code == 200
    data = response.json()
    upserted_ids = [t["id"] for t in data["transactions"]["upserted"]]
    assert new_tx.id in upserted_ids
    assert old_tx.id not in upserted_ids


def test_incremental_pull_returns_deleted_ids(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")

    tx = create_transaction(user=user)
    since = timezone.now()

    tx.is_deleted = True
    tx.deleted_at = timezone.now()
    tx.save()

    response = client.get(
        sync_pull_url() + f"?since={since.isoformat()}",
        **auth_headers(token),
    )

    data = response.json()
    assert tx.id in data["transactions"]["deleted_ids"]
    assert len(data["transactions"]["upserted"]) == 0


def test_incremental_pull_skips_unchanged_settings(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    # Ensure settings exist
    UserSettings.objects.get_or_create(user=user)

    since = (timezone.now() + timedelta(seconds=1)).isoformat()

    response = client.get(
        sync_pull_url() + f"?since={since}",
        **auth_headers(token),
    )

    data = response.json()
    assert data["settings"] is None


def test_pull_invalid_since_returns_400(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.get(
        sync_pull_url() + "?since=not-a-date",
        **auth_headers(token),
    )

    assert response.status_code == 400




def test_pull_does_not_leak_other_user_data(client):
    user1 = create_user(email="user1@example.com")
    user2 = create_user(email="user2@example.com")
    token1 = access_token_for(client, email=user1.email, password="ComplexPass12345")

    create_transaction(user=user1, amount="10.00")
    create_transaction(user=user2, amount="20.00")

    response = client.get(sync_pull_url(), **auth_headers(token1))

    data = response.json()
    assert len(data["transactions"]["upserted"]) == 1




def test_push_create_transaction(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    client_id = str(uuid.uuid4())

    response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "created": [
                    {
                        "client_id": client_id,
                        "category_code": "food",
                        "description": "Lunch",
                        "original_amount": "15.50",
                        "original_currency": "PLN",
                        "transaction_date": "2026-03-15",
                    }
                ],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200
    data = response.json()

    assert len(data["id_mappings"]) == 1
    mapping = data["id_mappings"][0]
    assert mapping["client_id"] == client_id
    assert mapping["server_id"] > 0

    tx = Transaction.objects.get(id=mapping["server_id"])
    assert tx.user == user
    assert tx.description == "Lunch"
    assert tx.original_amount == Decimal("15.50")
    assert tx.category.code == "food"




def test_push_update_transaction(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)

    response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "updated": [
                    {
                        "id": tx.id,
                        "description": "Updated description",
                        "updated_at": tx.updated_at.isoformat(),
                    }
                ],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["conflicts"]) == 0

    tx.refresh_from_db()
    assert tx.description == "Updated description"


def test_push_update_conflict_returns_server_version(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)

    stale_updated_at = tx.updated_at - timedelta(seconds=10)

    # Simulate server-side change
    tx.description = "Server changed this"
    tx.save()

    response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "updated": [
                    {
                        "id": tx.id,
                        "description": "Client wants this",
                        "updated_at": stale_updated_at.isoformat(),
                    }
                ],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["conflicts"]) == 1
    assert data["conflicts"][0]["id"] == tx.id
    assert data["conflicts"][0]["server_version"]["description"] == "Server changed this"

    tx.refresh_from_db()
    assert tx.description == "Server changed this"




def test_push_delete_transaction(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)

    response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "deleted": [{"id": tx.id}],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200
    tx.refresh_from_db()
    assert tx.is_deleted is True
    assert tx.deleted_at is not None


def test_push_delete_already_deleted_is_noop(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")
    tx = create_transaction(user=user)
    tx.is_deleted = True
    tx.deleted_at = timezone.now()
    tx.save()

    response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "deleted": [{"id": tx.id}],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200




def test_push_settings_update(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        sync_push_url(),
        data={
            "settings": {
                "preferred_language": "pl",
                "preferred_currency": "EUR",
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )

    assert response.status_code == 200
    data = response.json()
    assert data["settings"]["preferred_language"] == "pl"
    assert data["settings"]["preferred_currency"] == "EUR"

    settings = UserSettings.objects.get(user=user)
    assert settings.preferred_language == "pl"
    assert settings.preferred_currency == "EUR"




def test_push_then_pull_round_trip(client):
    user = create_user()
    token = access_token_for(client, email=user.email, password="ComplexPass12345")

    since = timezone.now()
    client_id = str(uuid.uuid4())

    # Push a new transaction
    push_response = client.post(
        sync_push_url(),
        data={
            "transactions": {
                "created": [
                    {
                        "client_id": client_id,
                        "category_code": "transport",
                        "description": "Bus ticket",
                        "original_amount": "5.00",
                        "original_currency": "PLN",
                        "transaction_date": "2026-03-20",
                    }
                ],
            },
        },
        content_type="application/json",
        **auth_headers(token),
    )
    server_id = push_response.json()["id_mappings"][0]["server_id"]

    # Pull changes since before the push
    pull_response = client.get(
        sync_pull_url() + f"?since={since.isoformat()}",
        **auth_headers(token),
    )

    data = pull_response.json()
    upserted_ids = [t["id"] for t in data["transactions"]["upserted"]]
    assert server_id in upserted_ids
