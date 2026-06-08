import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.common.constants import DEFAULT_CURRENCY_CODE, DEFAULT_LANGUAGE_CODE
from apps.preferences.models import UserSettings

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def register_url() -> str:
    return reverse("auth-register", kwargs={"version": "v1"})


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def me_url() -> str:
    return reverse("auth-me", kwargs={"version": "v1"})


def refresh_url() -> str:
    return reverse("auth-refresh", kwargs={"version": "v1"})


def test_successful_registration_returns_user_and_tokens(client):
    response = client.post(
        register_url(),
        data={
            "email": "User@example.com",
            "password": "ComplexPass12345",
            "password_confirm": "ComplexPass12345",
        },
        content_type="application/json",
    )

    assert response.status_code == 201
    payload = response.json()

    assert payload["user"]["email"] == "user@example.com"
    assert payload["user"]["settings"] == {
        "preferred_language": DEFAULT_LANGUAGE_CODE,
        "preferred_currency": DEFAULT_CURRENCY_CODE,
    }
    assert payload["tokens"]["access"]
    assert payload["tokens"]["refresh"]

    user = User.objects.get(email="user@example.com")
    assert user.username == "user@example.com"
    assert user.check_password("ComplexPass12345")

    settings = UserSettings.objects.get(user=user)
    assert settings.preferred_language == DEFAULT_LANGUAGE_CODE
    assert settings.preferred_currency == DEFAULT_CURRENCY_CODE


def test_duplicate_email_registration_fails(client):
    User.objects.create_user(email="taken@example.com", password="ComplexPass12345")

    response = client.post(
        register_url(),
        data={
            "email": "TAKEN@example.com",
            "password": "ComplexPass12345",
            "password_confirm": "ComplexPass12345",
        },
        content_type="application/json",
    )

    assert response.status_code == 400
    assert response.json() == {"email": ["A user with this email already exists."]}


def test_password_confirmation_mismatch_fails(client):
    response = client.post(
        register_url(),
        data={
            "email": "user@example.com",
            "password": "ComplexPass12345",
            "password_confirm": "ComplexPass99999",
        },
        content_type="application/json",
    )

    assert response.status_code == 400
    assert response.json() == {
        "password_confirm": ["Password confirmation does not match."]
    }


def test_successful_login_returns_user_and_tokens(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")

    response = client.post(
        login_url(),
        data={
            "email": "USER@example.com",
            "password": "ComplexPass12345",
        },
        content_type="application/json",
    )

    assert response.status_code == 200
    payload = response.json()

    assert payload["user"]["id"] == user.id
    assert payload["user"]["email"] == user.email
    assert payload["user"]["settings"] == {
        "preferred_language": DEFAULT_LANGUAGE_CODE,
        "preferred_currency": DEFAULT_CURRENCY_CODE,
    }
    assert payload["tokens"]["access"]
    assert payload["tokens"]["refresh"]


def test_invalid_login_returns_validation_error(client):
    User.objects.create_user(email="user@example.com", password="ComplexPass12345")

    response = client.post(
        login_url(),
        data={
            "email": "user@example.com",
            "password": "wrong-password",
        },
        content_type="application/json",
    )

    assert response.status_code == 400
    assert response.json() == {"detail": ["Invalid email or password."]}


def test_authenticated_user_can_fetch_current_profile(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = client.post(
        login_url(),
        data={
            "email": user.email,
            "password": "ComplexPass12345",
        },
        content_type="application/json",
    ).json()["tokens"]["access"]

    response = client.get(me_url(), **auth_headers(access_token))

    assert response.status_code == 200
    payload = response.json()

    assert payload["id"] == user.id
    assert payload["email"] == user.email
    assert payload["settings"] == {
        "preferred_language": DEFAULT_LANGUAGE_CODE,
        "preferred_currency": DEFAULT_CURRENCY_CODE,
    }
    assert payload["date_joined"].startswith(user.date_joined.date().isoformat())


def test_refresh_endpoint_returns_rotated_token_pair(client):
    User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    login_response = client.post(
        login_url(),
        data={
            "email": "user@example.com",
            "password": "ComplexPass12345",
        },
        content_type="application/json",
    )

    response = client.post(
        refresh_url(),
        data={"refresh": login_response.json()["tokens"]["refresh"]},
        content_type="application/json",
    )

    assert response.status_code == 200
    assert response.json()["access"]
    assert response.json()["refresh"]


def test_current_user_endpoint_rejects_unauthenticated_requests(client):
    response = client.get(me_url())

    assert response.status_code == 401
