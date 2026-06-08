from datetime import date

import pytest
from django.contrib.auth import get_user_model
from django.urls import reverse

from apps.categories.models import Category
from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.ml.models import CategoryPredictionFeedback
from apps.transactions.models import Transaction

pytestmark = pytest.mark.django_db

User = get_user_model()


def auth_headers(access_token: str) -> dict[str, str]:
    return {
        "HTTP_AUTHORIZATION": f"Bearer {access_token}",
    }


def login_url() -> str:
    return reverse("auth-login", kwargs={"version": "v1"})


def prediction_url() -> str:
    return reverse("category-predictions", kwargs={"version": "v1"})


def feedback_url() -> str:
    return reverse("category-prediction-feedback", kwargs={"version": "v1"})


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


def test_prediction_and_feedback_endpoints_require_authentication(client):
    prediction_response = client.post(
        prediction_url(),
        data={"input_text": "Uber airport parking"},
        content_type="application/json",
    )
    feedback_response = client.post(
        feedback_url(),
        data={
            "input_text": "Uber airport parking",
            "selected_category_code": "transport",
        },
        content_type="application/json",
    )

    assert prediction_response.status_code == 401
    assert feedback_response.status_code == 401


def test_keyword_prediction_returns_transport_for_clear_match(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        prediction_url(),
        data={"input_text": "Uber airport parking"},
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json() == {
        "input_text": "Uber airport parking",
        "status": "predicted",
        "confidence": "0.85",
        "predicted_category_code": "transport",
        "predicted_category": {
            "code": "transport",
            "default_label": "Transport",
            "label": "Transport",
            "icon_key": "bus",
            "color": "#3B82F6",
            "sort_order": 20,
            "is_active": True,
        },
        "candidates": [
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
                "score": "1.00",
            }
        ],
        "classifier_version": "hybrid_category_classifier_v1",
        "strategy": "keyword_rules_v1",
    }


def test_prediction_supports_multilingual_keywords_and_localized_labels(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    user.settings.preferred_language = "pl"
    user.settings.save(update_fields=["preferred_language"])
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        prediction_url(),
        data={"input_text": "Apteka i lekarz"},
        content_type="application/json",
        **auth_headers(access_token),
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["status"] == "predicted"
    assert payload["confidence"] == "0.85"
    assert payload["predicted_category_code"] == "health"
    assert payload["predicted_category"]["label"] == "Zdrowie"


def test_prediction_returns_uncertain_when_multiple_categories_compete(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        prediction_url(),
        data={"input_text": "uber coffee"},
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json() == {
        "input_text": "uber coffee",
        "status": "uncertain",
        "confidence": "0.59",
        "predicted_category_code": "transport",
        "predicted_category": {
            "code": "transport",
            "default_label": "Transport",
            "label": "Transport",
            "icon_key": "bus",
            "color": "#3B82F6",
            "sort_order": 20,
            "is_active": True,
        },
        "candidates": [
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
                "score": "0.57",
            },
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
                "score": "0.43",
            },
        ],
        "classifier_version": "hybrid_category_classifier_v1",
        "strategy": "keyword_rules_v1",
    }


def test_prediction_returns_no_match_for_unknown_text(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")

    response = client.post(
        prediction_url(),
        data={"input_text": "Quarterly budget sync"},
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 200
    assert response.json() == {
        "input_text": "Quarterly budget sync",
        "status": "no_match",
        "confidence": "0.00",
        "predicted_category_code": None,
        "predicted_category": None,
        "candidates": [],
        "classifier_version": "hybrid_category_classifier_v1",
        "strategy": "keyword_rules_v1",
    }


def test_feedback_persistence_stores_prediction_snapshot_and_transaction(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    transaction = create_transaction_for_user(
        user=user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="12.00",
    )

    response = client.post(
        feedback_url(),
        data={
            "input_text": "uber lunch",
            "selected_category_code": "food",
            "predicted_category_code": "transport",
            "predicted_confidence": "0.59",
            "predicted_status": "uncertain",
            "prediction_strategy": "keyword_rules_v1",
            "classifier_version": "hybrid_category_classifier_v1",
            "transaction_id": transaction.id,
        },
        content_type="application/json",
        **auth_headers(access_token),
    )
    payload = response.json()

    assert response.status_code == 201
    assert payload["selected_category_code"] == "food"
    assert payload["predicted_category_code"] == "transport"
    assert payload["predicted_status"] == "uncertain"
    assert payload["predicted_confidence"] == "0.59"
    assert payload["prediction_strategy"] == "keyword_rules_v1"
    assert payload["classifier_version"] == "hybrid_category_classifier_v1"
    assert payload["was_corrected"] is True
    assert payload["transaction_id"] == transaction.id

    feedback = CategoryPredictionFeedback.objects.get(id=payload["id"])
    assert feedback.user == user
    assert feedback.transaction == transaction
    assert feedback.input_text == "uber lunch"
    assert feedback.normalized_input_text == "uber lunch"
    assert feedback.selected_category.code == "food"
    assert feedback.predicted_category.code == "transport"
    assert feedback.was_corrected is True


def test_feedback_examples_drive_future_predictions_for_same_user_only(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    other_user = User.objects.create_user(email="other@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    other_access_token = access_token_for(
        client,
        email=other_user.email,
        password="ComplexPass12345",
    )

    feedback_response = client.post(
        feedback_url(),
        data={
            "input_text": "Acme monthly",
            "selected_category_code": "subscriptions_education",
            "predicted_status": "no_match",
            "prediction_strategy": "keyword_rules_v1",
            "classifier_version": "hybrid_category_classifier_v1",
        },
        content_type="application/json",
        **auth_headers(access_token),
    )
    user_prediction_response = client.post(
        prediction_url(),
        data={"input_text": "Acme monthly"},
        content_type="application/json",
        **auth_headers(access_token),
    )
    other_prediction_response = client.post(
        prediction_url(),
        data={"input_text": "Acme monthly"},
        content_type="application/json",
        **auth_headers(other_access_token),
    )

    assert feedback_response.status_code == 201
    assert user_prediction_response.status_code == 200
    assert user_prediction_response.json() == {
        "input_text": "Acme monthly",
        "status": "predicted",
        "confidence": "0.92",
        "predicted_category_code": "subscriptions_education",
        "predicted_category": {
            "code": "subscriptions_education",
            "default_label": "Subscriptions / Education",
            "label": "Subscriptions / Education",
            "icon_key": "book-open",
            "color": "#06B6D4",
            "sort_order": 90,
            "is_active": True,
        },
        "candidates": [
            {
                "category_code": "subscriptions_education",
                "category": {
                    "code": "subscriptions_education",
                    "default_label": "Subscriptions / Education",
                    "label": "Subscriptions / Education",
                    "icon_key": "book-open",
                    "color": "#06B6D4",
                    "sort_order": 90,
                    "is_active": True,
                },
                "score": "1.00",
            }
        ],
        "classifier_version": "hybrid_category_classifier_v1",
        "strategy": "feedback_memory_v1",
    }
    assert other_prediction_response.status_code == 200
    assert other_prediction_response.json()["status"] == "no_match"
    assert other_prediction_response.json()["predicted_category_code"] is None


def test_feedback_rejects_transaction_from_another_user(client):
    user = User.objects.create_user(email="user@example.com", password="ComplexPass12345")
    other_user = User.objects.create_user(email="other@example.com", password="ComplexPass12345")
    access_token = access_token_for(client, email=user.email, password="ComplexPass12345")
    other_transaction = create_transaction_for_user(
        user=other_user,
        category_code="food",
        transaction_date=date(2026, 3, 10),
        amount="12.00",
    )

    response = client.post(
        feedback_url(),
        data={
            "input_text": "Lunch",
            "selected_category_code": "food",
            "transaction_id": other_transaction.id,
        },
        content_type="application/json",
        **auth_headers(access_token),
    )

    assert response.status_code == 400
    assert response.json() == {
        "transaction_id": ["Transaction must belong to the authenticated user."]
    }
