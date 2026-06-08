import pytest
from django.conf import settings
from django.urls import reverse

pytestmark = pytest.mark.django_db


def test_root_endpoint(client):
    response = client.get(reverse("root"))

    assert response.status_code == 200
    assert response.json()["project"] == settings.PROJECT_NAME


def test_health_endpoint(client):
    response = client.get(reverse("health"))

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
