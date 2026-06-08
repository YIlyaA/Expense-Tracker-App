from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from rest_framework.permissions import AllowAny

from .views import health_view, root_view

urlpatterns = [
    path("", root_view, name="root"),
    path("health/", health_view, name="health"),
    path(settings.ADMIN_URL, admin.site.urls),
    path("accounts/", include("allauth.urls")),
    path("api/<str:version>/auth/", include("apps.users.api.urls")),
    path("api/<str:version>/categories/", include("apps.categories.api.urls")),
    path("api/<str:version>/", include("apps.insights.api.urls")),
    path("api/<str:version>/ml/", include("apps.ml.api.urls")),
    path("api/<str:version>/settings/", include("apps.preferences.api.urls")),
    path("api/<str:version>/transactions/", include("apps.transactions.api.urls")),
    path("api/<str:version>/sync/", include("apps.sync.api.urls")),
    path(
        "api/schema/",
        SpectacularAPIView.as_view(
            api_version="v1",
            permission_classes=[AllowAny],
            authentication_classes=[],
        ),
        name="api-schema",
    ),
    path(
        "api/docs/",
        SpectacularSwaggerView.as_view(
            permission_classes=[AllowAny],
            authentication_classes=[],
            url_name="api-schema",
        ),
        name="api-docs",
    ),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
