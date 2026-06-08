from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions
from rest_framework.response import Response

from apps.insights.api.serializers import (
    DashboardResponseSerializer,
    InsightsResponseSerializer,
    StatisticsQuerySerializer,
    StatisticsResponseSerializer,
    build_currency_context,
)
from apps.insights.generation import build_generated_insights
from apps.insights.services import build_dashboard_data, build_statistics_data, resolve_period
from apps.preferences.models import UserSettings


class PreferenceContextMixin:
    permission_classes = [permissions.IsAuthenticated]

    def get_user_settings(self) -> UserSettings:
        user_settings, _ = UserSettings.objects.get_or_create(user=self.request.user)
        return user_settings

    def serializer_context_data(self) -> dict[str, str]:
        user_settings = self.get_user_settings()
        return {
            "display_currency": user_settings.preferred_currency,
            "category_language": user_settings.preferred_language,
            "message_language": user_settings.preferred_language,
        }


class DashboardView(PreferenceContextMixin, generics.GenericAPIView):
    serializer_class = DashboardResponseSerializer

    @extend_schema(tags=["Dashboard"], responses=DashboardResponseSerializer)
    def get(self, request, *args, **kwargs):
        serializer_context = self.serializer_context_data()
        payload = build_dashboard_data(user=request.user)
        payload["currency_context"] = build_currency_context(
            display_currency=serializer_context["display_currency"]
        )
        serializer = self.get_serializer(payload, context=serializer_context)
        return Response(serializer.data)


class StatisticsView(PreferenceContextMixin, generics.GenericAPIView):
    serializer_class = StatisticsResponseSerializer

    @extend_schema(
        tags=["Statistics"],
        parameters=[StatisticsQuerySerializer],
        responses=StatisticsResponseSerializer,
    )
    def get(self, request, *args, **kwargs):
        query_serializer = StatisticsQuerySerializer(data=request.query_params)
        query_serializer.is_valid(raise_exception=True)
        serializer_context = self.serializer_context_data()
        payload = build_statistics_data(
            user=request.user,
            period=resolve_period(**query_serializer.validated_data),
        )
        payload["currency_context"] = build_currency_context(
            display_currency=serializer_context["display_currency"]
        )
        serializer = self.get_serializer(payload, context=serializer_context)
        return Response(serializer.data)


class GeneratedInsightsView(PreferenceContextMixin, generics.GenericAPIView):
    serializer_class = InsightsResponseSerializer

    @extend_schema(tags=["Insights"], responses=InsightsResponseSerializer)
    def get(self, request, *args, **kwargs):
        serializer_context = self.serializer_context_data()
        payload = build_generated_insights(
            user=request.user,
            display_currency=serializer_context["display_currency"],
            language_code=serializer_context["message_language"],
        )
        payload["currency_context"] = build_currency_context(
            display_currency=serializer_context["display_currency"]
        )
        serializer = self.get_serializer(payload, context=serializer_context)
        return Response(serializer.data)
