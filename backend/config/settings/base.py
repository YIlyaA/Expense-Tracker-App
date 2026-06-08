from datetime import timedelta
from pathlib import Path

import environ

from apps.common.constants import DEFAULT_CURRENCY_CODE as APP_DEFAULT_CURRENCY_CODE
from apps.common.constants import DEFAULT_LANGUAGE_CODE, SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import AppLanguage, CurrencyCode
from apps.common.validators import validate_setting_choice

BASE_DIR = Path(__file__).resolve().parents[2]
APPS_DIR = BASE_DIR / "apps"

env = environ.Env(
    DJANGO_ADMIN_URL=(str, "admin/"),
    DJANGO_ALLOWED_HOSTS=(list, []),
    DJANGO_API_PAGE_SIZE=(int, 20),
    DJANGO_API_THROTTLE_ANON=(str, "60/minute"),
    DJANGO_API_THROTTLE_USER=(str, "120/minute"),
    DJANGO_AXES_COOLOFF_HOURS=(int, 1),
    DJANGO_AXES_ENABLED=(bool, True),
    DJANGO_AXES_FAILURE_LIMIT=(int, 5),
    DJANGO_CELERY_TASK_SOFT_TIME_LIMIT=(int, 240),
    DJANGO_CELERY_TASK_TIME_LIMIT=(int, 300),
    DJANGO_CORS_ALLOW_ALL_ORIGINS=(bool, False),
    DJANGO_CORS_ALLOW_CREDENTIALS=(bool, True),
    DJANGO_CORS_ALLOWED_ORIGINS=(list, []),
    DJANGO_CSRF_TRUSTED_ORIGINS=(list, []),
    DJANGO_DB_ATOMIC_REQUESTS=(bool, True),
    DJANGO_DB_CONN_MAX_AGE=(int, 60),
    DJANGO_DEBUG=(bool, False),
    DJANGO_DEFAULT_FROM_EMAIL=(str, "noreply@example.com"),
    DJANGO_EMAIL_BACKEND=(str, "django.core.mail.backends.smtp.EmailBackend"),
    DJANGO_EMAIL_HOST=(str, "localhost"),
    DJANGO_EMAIL_PORT=(int, 1025),
    DJANGO_EMAIL_USE_SSL=(bool, False),
    DJANGO_EMAIL_USE_TLS=(bool, False),
    DJANGO_JWT_ACCESS_MINUTES=(int, 5),
    DJANGO_JWT_REFRESH_DAYS=(int, 7),
    DJANGO_LANGUAGE_CODE=(str, DEFAULT_LANGUAGE_CODE),
    DJANGO_LOGIN_REDIRECT_URL=(str, "/"),
    DJANGO_LOG_LEVEL=(str, "INFO"),
    DJANGO_LOGOUT_REDIRECT_URL=(str, "/"),
    DJANGO_PROJECT_NAME=(str, "Expense Tracker API"),
    DJANGO_SERVER_EMAIL=(str, "server@example.com"),
    DJANGO_SITE_ID=(int, 1),
    DJANGO_SITE_NAME=(str, "Expense Tracker"),
    DJANGO_TIME_ZONE=(str, "UTC"),
)

DEBUG = env("DJANGO_DEBUG")
SECRET_KEY = env("DJANGO_SECRET_KEY")
ALLOWED_HOSTS = env("DJANGO_ALLOWED_HOSTS")
CSRF_TRUSTED_ORIGINS = env("DJANGO_CSRF_TRUSTED_ORIGINS")
ADMIN_URL = env("DJANGO_ADMIN_URL")
PROJECT_NAME = env("DJANGO_PROJECT_NAME")
SITE_ID = env("DJANGO_SITE_ID")
SITE_NAME = env("DJANGO_SITE_NAME")

DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.sites",
    "django.contrib.staticfiles",
]

THIRD_PARTY_APPS = [
    "axes",
    "allauth",
    "allauth.account",
    "allauth.socialaccount",
    "allauth.socialaccount.providers.apple",
    "allauth.socialaccount.providers.google",
    "corsheaders",
    "django_filters",
    "drf_spectacular",
    "rest_framework",
]

LOCAL_APPS = [
    "apps.common",
    "apps.categories",
    "apps.currency",
    "apps.insights",
    "apps.ml",
    "apps.preferences",
    "apps.transactions",
    "apps.users",
    "apps.sync",
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.locale.LocaleMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "allauth.account.middleware.AccountMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "axes.middleware.AxesMiddleware",
]

ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

DATABASES = {
    "default": env.db("DATABASE_URL"),
}
DATABASES["default"]["ATOMIC_REQUESTS"] = env("DJANGO_DB_ATOMIC_REQUESTS")
DATABASES["default"]["CONN_MAX_AGE"] = env("DJANGO_DB_CONN_MAX_AGE")

AUTH_USER_MODEL = "users.User"

AUTHENTICATION_BACKENDS = [
    "axes.backends.AxesStandaloneBackend",
    "django.contrib.auth.backends.ModelBackend",
    "allauth.account.auth_backends.AuthenticationBackend",
]

PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.Argon2PasswordHasher",
    "django.contrib.auth.hashers.PBKDF2PasswordHasher",
    "django.contrib.auth.hashers.BCryptSHA256PasswordHasher",
    "django.contrib.auth.hashers.ScryptPasswordHasher",
]

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {"min_length": 12},
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LOGIN_REDIRECT_URL = env("DJANGO_LOGIN_REDIRECT_URL")
LOGOUT_REDIRECT_URL = env("DJANGO_LOGOUT_REDIRECT_URL")

ACCOUNT_DEFAULT_HTTP_PROTOCOL = "http" if DEBUG else "https"

CORS_ALLOWED_ORIGINS = env("DJANGO_CORS_ALLOWED_ORIGINS")
CORS_ALLOW_ALL_ORIGINS = env("DJANGO_CORS_ALLOW_ALL_ORIGINS")
CORS_ALLOW_CREDENTIALS = env("DJANGO_CORS_ALLOW_CREDENTIALS")
CORS_URLS_REGEX = r"^/api/.*$"

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
    ],
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_FILTER_BACKENDS": [
        "django_filters.rest_framework.DjangoFilterBackend",
        "rest_framework.filters.SearchFilter",
        "rest_framework.filters.OrderingFilter",
    ],
    "DEFAULT_THROTTLE_CLASSES": [
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "anon": env("DJANGO_API_THROTTLE_ANON"),
        "user": env("DJANGO_API_THROTTLE_USER"),
    },
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": env("DJANGO_API_PAGE_SIZE"),
    "DEFAULT_VERSIONING_CLASS": "rest_framework.versioning.URLPathVersioning",
    "DEFAULT_VERSION": "v1",
    "ALLOWED_VERSIONS": ("v1",),
    "VERSION_PARAM": "version",
}

SPECTACULAR_SETTINGS = {
    "TITLE": PROJECT_NAME,
    "DESCRIPTION": "Foundation schema for the Expense Tracker mobile backend.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=env("DJANGO_JWT_ACCESS_MINUTES")),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=env("DJANGO_JWT_REFRESH_DAYS")),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": False,
    "UPDATE_LAST_LOGIN": True,
}

AXES_ENABLED = env("DJANGO_AXES_ENABLED")
AXES_FAILURE_LIMIT = env("DJANGO_AXES_FAILURE_LIMIT")
AXES_COOLOFF_TIME = timedelta(hours=env("DJANGO_AXES_COOLOFF_HOURS"))
AXES_RESET_ON_SUCCESS = True
AXES_LOCKOUT_PARAMETERS = ["username", "ip_address"]

LANGUAGE_CODE = validate_setting_choice(
    env("DJANGO_LANGUAGE_CODE"),
    supported_values=AppLanguage.values(),
    setting_name="DJANGO_LANGUAGE_CODE",
)
LANGUAGES = AppLanguage.choices()
SUPPORTED_LANGUAGE_CODES = AppLanguage.values()
DEFAULT_CURRENCY_CODE = APP_DEFAULT_CURRENCY_CODE
SYSTEM_BASE_CURRENCY = SYSTEM_BASE_CURRENCY_CODE
SUPPORTED_CURRENCY_CODES = CurrencyCode.values()
LOCALE_PATHS = [BASE_DIR / "locale"]
TIME_ZONE = env("DJANGO_TIME_ZONE")
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_FROM_EMAIL = env("DJANGO_DEFAULT_FROM_EMAIL")
SERVER_EMAIL = env("DJANGO_SERVER_EMAIL")
EMAIL_BACKEND = env("DJANGO_EMAIL_BACKEND")
EMAIL_HOST = env("DJANGO_EMAIL_HOST")
EMAIL_PORT = env("DJANGO_EMAIL_PORT")
EMAIL_USE_TLS = env("DJANGO_EMAIL_USE_TLS")
EMAIL_USE_SSL = env("DJANGO_EMAIL_USE_SSL")
EMAIL_HOST_USER = env("DJANGO_EMAIL_HOST_USER", default="")
EMAIL_HOST_PASSWORD = env("DJANGO_EMAIL_HOST_PASSWORD", default="")

PASSWORD_RESET_TIMEOUT = 60 * 60 * 24

SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SAMESITE = "Lax"
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_REFERRER_POLICY = "strict-origin-when-cross-origin"
X_FRAME_OPTIONS = "DENY"

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "tenis-matchmaking-local-cache",
    }
}

SESSION_ENGINE = "django.contrib.sessions.backends.db"

REDIS_URL = env("REDIS_URL", default="redis://127.0.0.1:6379/0")
CELERY_BROKER_URL = env("CELERY_BROKER_URL", default=REDIS_URL)
CELERY_RESULT_BACKEND = env("CELERY_RESULT_BACKEND", default="redis://127.0.0.1:6379/1")
CELERY_ACCEPT_CONTENT = ["json"]
CELERY_TASK_SERIALIZER = "json"
CELERY_RESULT_SERIALIZER = "json"
CELERY_TIMEZONE = TIME_ZONE
CELERY_TASK_TIME_LIMIT = env("DJANGO_CELERY_TASK_TIME_LIMIT")
CELERY_TASK_SOFT_TIME_LIMIT = env("DJANGO_CELERY_TASK_SOFT_TIME_LIMIT")

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "%(asctime)s %(levelname)s %(name)s %(message)s",
        },
        "simple": {
            "format": "%(levelname)s %(message)s",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose" if not DEBUG else "simple",
        }
    },
    "root": {
        "handlers": ["console"],
        "level": env("DJANGO_LOG_LEVEL"),
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": env("DJANGO_LOG_LEVEL"),
            "propagate": False,
        },
        "django.request": {
            "handlers": ["console"],
            "level": "ERROR",
            "propagate": False,
        },
    },
}

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

SOCIALACCOUNT_PROVIDERS = {
    "google": {
        "SCOPE": ["profile", "email"],
        "AUTH_PARAMS": {"access_type": "online"},
        "OAUTH_PKCE_ENABLED": True,
    },
    "apple": {},
}

google_client_id = env("GOOGLE_OAUTH_CLIENT_ID", default="")
google_client_secret = env("GOOGLE_OAUTH_CLIENT_SECRET", default="")
if google_client_id and google_client_secret:
    SOCIALACCOUNT_PROVIDERS["google"]["APPS"] = [
        {
            "client_id": google_client_id,
            "secret": google_client_secret,
            "key": "",
            "settings": {
                "scope": ["profile", "email"],
            },
        }
    ]

apple_client_id = env("APPLE_OAUTH_CLIENT_ID", default="")
apple_secret = env("APPLE_OAUTH_SECRET", default="")
apple_key = env("APPLE_OAUTH_KEY", default="")
apple_certificate_key = env("APPLE_OAUTH_CERTIFICATE_KEY", default="")
if apple_client_id and apple_secret and apple_key and apple_certificate_key:
    SOCIALACCOUNT_PROVIDERS["apple"]["APPS"] = [
        {
            "client_id": apple_client_id,
            "secret": apple_secret,
            "key": apple_key,
            "settings": {
                "certificate_key": apple_certificate_key,
            },
        }
    ]
