from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions

from apps.preferences.api.serializers import UserSettingsSerializer
from apps.preferences.models import UserSettings


class UserSettingsView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSettingsSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ["get", "patch"]

    @extend_schema(tags=["Settings"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Settings"])
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)

    def get_object(self) -> UserSettings:
        user_settings, _ = UserSettings.objects.get_or_create(user=self.request.user)
        return user_settings
