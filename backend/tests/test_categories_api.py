import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.categories.defaults import DEFAULT_CATEGORY_CODES
from apps.categories.models import Category

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def categories_url() -> str:
    return reverse("categories-list", kwargs={"version": "v1"})


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


def test_default_categories_are_seeded_after_migrate():
    categories = list(Category.objects.values_list("code", flat=True))

    assert categories == list(DEFAULT_CATEGORY_CODES)
    assert Category.objects.count() == 11


def test_seeded_category_codes_are_unique_and_stable():
    codes = list(Category.objects.values_list("code", flat=True))

    assert len(codes) == len(set(codes))
    assert tuple(codes) == DEFAULT_CATEGORY_CODES


def test_authenticated_user_can_list_categories(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(
        client,
        email=user.email,
        password="ComplexPass12345",
    )

    response = client.get(categories_url(), **auth_headers(access_token))

    assert response.status_code == 200
    payload = response.json()

    assert isinstance(payload, list)
    assert len(payload) == len(DEFAULT_CATEGORY_CODES)
    assert payload[0] == {
        "code": "food",
        "default_label": "Food",
        "label": "Food",
        "icon_key": "utensils",
        "color": "#EF4444",
        "sort_order": 10,
        "is_active": True,
    }


def test_categories_endpoint_rejects_unauthenticated_requests(client):
    response = client.get(categories_url())

    assert response.status_code == 401


def test_category_labels_follow_user_preferred_language(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    user.settings.preferred_language = "pl"
    user.settings.save(update_fields=["preferred_language"])
    access_token = access_token_for(
        client,
        email=user.email,
        password="ComplexPass12345",
    )

    response = client.get(categories_url(), **auth_headers(access_token))
    payload = response.json()
    food_category = next(item for item in payload if item["code"] == "food")
    top_ups_category = next(item for item in payload if item["code"] == "top_ups")

    assert response.status_code == 200
    assert food_category["label"] == "Jedzenie"
    assert top_ups_category["label"] == "Doładowania"


def test_inactive_categories_are_hidden_from_the_api(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(
        client,
        email=user.email,
        password="ComplexPass12345",
    )
    Category.objects.filter(code="other").update(is_active=False)

    response = client.get(categories_url(), **auth_headers(access_token))
    payload = response.json()
    codes = [item["code"] for item in payload]

    assert response.status_code == 200
    assert "other" not in codes
