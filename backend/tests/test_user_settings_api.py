import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.common.constants import DEFAULT_CURRENCY_CODE, DEFAULT_LANGUAGE_CODE

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def settings_url() -> str:
    return reverse("settings-me", kwargs={"version": "v1"})


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


def test_authenticated_user_can_retrieve_own_settings(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(
        client,
        email=user.email,
        password="ComplexPass12345",
    )

    response = client.get(settings_url(), **auth_headers(access_token))

    assert response.status_code == 200
    assert response.json() == {
        "preferred_language": DEFAULT_LANGUAGE_CODE,
        "preferred_currency": DEFAULT_CURRENCY_CODE,
    }


def test_authenticated_user_can_update_own_settings(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(
        client,
        email=user.email,
        password="ComplexPass12345",
    )

    response = client.patch(
        settings_url(),
        data={
            "preferred_language": "pl",
            "preferred_currency": "USD",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json() == {
        "preferred_language": "pl",
        "preferred_currency": "USD",
    }


def test_settings_endpoint_rejects_unauthenticated_requests(client):
    response = client.get(settings_url())

    assert response.status_code == 401


def test_settings_are_isolated_per_authenticated_user(client):
    first_user = User.objects.create_user(
        email="first@example.com",
        password="ComplexPass12345",
    )
    second_user = User.objects.create_user(
        email="second@example.com",
        password="ComplexPass12345",
    )
    first_access_token = access_token_for(
        client,
        email=first_user.email,
        password="ComplexPass12345",
    )
    second_access_token = access_token_for(
        client,
        email=second_user.email,
        password="ComplexPass12345",
    )

    patch_response = client.patch(
        settings_url(),
        data={
            "preferred_language": "ru",
            "preferred_currency": "EUR",
        },
        content_type="application/json",
        **auth_headers(first_access_token),
    )
    second_response = client.get(settings_url(), **auth_headers(second_access_token))

    assert patch_response.status_code == 200
    assert second_response.status_code == 200
    assert second_response.json() == {
        "preferred_language": DEFAULT_LANGUAGE_CODE,
        "preferred_currency": DEFAULT_CURRENCY_CODE,
    }
