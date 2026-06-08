from django.utils import timezone
from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions

from apps.preferences.models import UserSettings
from apps.transactions.api.filters import TransactionFilterSet
from apps.transactions.api.serializers import TransactionSerializer
from apps.transactions.models import Transaction


class TransactionContextMixin:
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Transaction.objects.filter(
            user=self.request.user, is_deleted=False
        ).select_related("category")

    def get_serializer_context(self) -> dict[str, object]:
        context = super().get_serializer_context()
        user_settings, _ = UserSettings.objects.get_or_create(user=self.request.user)
        context["category_language"] = user_settings.preferred_language
        context["display_currency"] = user_settings.preferred_currency
        return context


class TransactionListCreateView(TransactionContextMixin, generics.ListCreateAPIView):
    filterset_class = TransactionFilterSet
    ordering_fields = ("transaction_date", "created_at", "original_amount", "base_amount")

    @extend_schema(tags=["Transactions"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Transactions"])
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class TransactionDetailView(TransactionContextMixin, generics.RetrieveUpdateDestroyAPIView):
    http_method_names = ["get", "patch", "delete"]

    @extend_schema(tags=["Transactions"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @extend_schema(tags=["Transactions"])
    def patch(self, request, *args, **kwargs):
        return super().patch(request, *args, **kwargs)

    @extend_schema(tags=["Transactions"])
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

    def perform_destroy(self, instance):
        instance.is_deleted = True
        instance.deleted_at = timezone.now()
        instance.save()
