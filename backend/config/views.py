from django.conf import settings
from django.http import JsonResponse


def root_view(request):
    return JsonResponse(
        {
            "project": settings.PROJECT_NAME,
            "status": "ok",
        }
    )


def health_view(request):
    return JsonResponse({"status": "ok"})
