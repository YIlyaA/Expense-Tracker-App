import pytest
from django.conf import settings
from django.urls import reverse

pytestmark = pytest.mark.django_db


def test_schema_endpoint_is_public(client):
    response = client.get(reverse("api-schema"))
    content = response.content.decode()

    assert response.status_code == 200
    assert "openapi:" in content
    assert settings.PROJECT_NAME in content
    assert "/api/v1/auth/register/" in content
    assert "/api/v1/auth/login/" in content
    assert "/api/v1/auth/me/" in content
    assert "/api/v1/auth/refresh/" in content
    assert "/api/v1/categories/" in content
    assert "/api/v1/dashboard/" in content
    assert "/api/v1/insights/" in content
    assert "/api/v1/ml/category-predictions/" in content
    assert "/api/v1/ml/category-feedback/" in content
    assert "/api/v1/settings/me/" in content
    assert "/api/v1/statistics/" in content
    assert "/api/v1/transactions/" in content


def test_docs_endpoint_is_public(client):
    response = client.get(reverse("api-docs"))

    assert response.status_code == 200
    assert "swagger-ui" in response.content.decode().lower()
