import os
from pathlib import Path

import environ

BASE_DIR = Path(__file__).resolve().parents[2]
env_file = BASE_DIR / ".envs" / ".env.prod"
custom_env_file = os.getenv("DJANGO_ENV_FILE")

if custom_env_file:
    custom_path = Path(custom_env_file)
    if not custom_path.is_absolute():
        custom_path = BASE_DIR / custom_path
    if custom_path.exists():
        environ.Env.read_env(custom_path)
elif (
    os.getenv("DJANGO_READ_DOT_ENV_FILE", "").lower() in {"1", "true", "yes"}
    and env_file.exists()
):
    environ.Env.read_env(env_file)

from .base import *  # noqa: E402,F403
from .base import env  # noqa: E402

DEBUG = False
ALLOWED_HOSTS = env("DJANGO_ALLOWED_HOSTS")
CSRF_TRUSTED_ORIGINS = env("DJANGO_CSRF_TRUSTED_ORIGINS")
CORS_ALLOWED_ORIGINS = env("DJANGO_CORS_ALLOWED_ORIGINS")
CORS_ALLOW_ALL_ORIGINS = False

USE_X_FORWARDED_HOST = env.bool("DJANGO_USE_X_FORWARDED_HOST", default=True)
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SECURE_SSL_REDIRECT = env.bool("DJANGO_SECURE_SSL_REDIRECT", default=True)
SECURE_HSTS_SECONDS = env.int("DJANGO_SECURE_HSTS_SECONDS", default=31536000)
SECURE_HSTS_INCLUDE_SUBDOMAINS = env.bool(
    "DJANGO_SECURE_HSTS_INCLUDE_SUBDOMAINS", default=True
)
SECURE_HSTS_PRELOAD = env.bool("DJANGO_SECURE_HSTS_PRELOAD", default=True)

STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.ManifestStaticFilesStorage",
    },
}

redis_cache_url = env("REDIS_CACHE_URL", default=env("REDIS_URL"))
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": redis_cache_url,
        "TIMEOUT": 60 * 60,
    }
}
SESSION_ENGINE = "django.contrib.sessions.backends.cached_db"

AXES_HANDLER = "axes.handlers.cache.AxesCacheHandler"
AXES_CACHE = "default"
AXES_IPWARE_PROXY_COUNT = env.int("DJANGO_AXES_IPWARE_PROXY_COUNT", default=1)
AXES_IPWARE_PROXY_TRUSTED_IPS = env.list(
    "DJANGO_AXES_IPWARE_PROXY_TRUSTED_IPS", default=[]
)
ACCOUNT_DEFAULT_HTTP_PROTOCOL = "https"
