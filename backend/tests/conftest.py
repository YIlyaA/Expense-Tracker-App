import pytest
from django.conf import settings


@pytest.fixture(autouse=True)
def disable_throttling():
    original = settings.REST_FRAMEWORK.get("DEFAULT_THROTTLE_CLASSES", [])
    settings.REST_FRAMEWORK["DEFAULT_THROTTLE_CLASSES"] = []
    yield
    settings.REST_FRAMEWORK["DEFAULT_THROTTLE_CLASSES"] = original
