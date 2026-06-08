from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions

from apps.categories.api.serializers import CategorySerializer
from apps.categories.models import Category
from apps.preferences.models import UserSettings


class CategoryListView(generics.ListAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    @extend_schema(tags=["Categories"], responses=CategorySerializer(many=True))
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return Category.objects.filter(is_active=True)

    def get_serializer_context(self) -> dict[str, object]:
        context = super().get_serializer_context()
        user_settings, _ = UserSettings.objects.get_or_create(user=self.request.user)
        context["category_language"] = user_settings.preferred_language
        return context
