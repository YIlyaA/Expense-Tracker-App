import os
from pathlib import Path

import environ

BASE_DIR = Path(__file__).resolve().parents[2]
env_file = BASE_DIR / ".envs" / ".env.local"

if env_file.exists():
    environ.Env.read_env(env_file)

os.environ.setdefault(
    "DJANGO_SECRET_KEY",
    "local-development-secret-key-change-before-production-1234567890",
)
os.environ.setdefault("DATABASE_URL", f"sqlite:///{BASE_DIR / 'db.sqlite3'}")
os.environ.setdefault("DJANGO_DEBUG", "true")
os.environ.setdefault("DJANGO_ALLOWED_HOSTS", "127.0.0.1,localhost,0.0.0.0")
os.environ.setdefault(
    "DJANGO_CSRF_TRUSTED_ORIGINS",
    "http://127.0.0.1:8000,http://localhost:8000,http://127.0.0.1:3000,http://localhost:3000",
)
os.environ.setdefault("DJANGO_CORS_ALLOW_ALL_ORIGINS", "true")
os.environ.setdefault("DJANGO_AXES_ENABLED", "false")
os.environ.setdefault("DJANGO_EMAIL_BACKEND", "django.core.mail.backends.console.EmailBackend")

from .base import *  # noqa: E402,F403
from .base import REST_FRAMEWORK  # noqa: E402

REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = [
    "rest_framework.renderers.JSONRenderer",
    "rest_framework.renderers.BrowsableAPIRenderer",
]
