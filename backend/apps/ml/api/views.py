from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions, status
from rest_framework.response import Response

from apps.ml.api.serializers import (
    CategoryPredictionFeedbackCreateSerializer,
    CategoryPredictionFeedbackResponseSerializer,
    CategoryPredictionRequestSerializer,
    CategoryPredictionResponseSerializer,
)
from apps.preferences.models import UserSettings


def serializer_context_data(*, user) -> dict[str, str]:
    user_settings, _ = UserSettings.objects.get_or_create(user=user)
    return {
        "category_language": user_settings.preferred_language,
    }


class CategoryPredictionView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CategoryPredictionRequestSerializer

    @extend_schema(
        tags=["ML"],
        request=CategoryPredictionRequestSerializer,
        responses=CategoryPredictionResponseSerializer,
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        prediction = serializer.create_prediction()
        response_serializer = CategoryPredictionResponseSerializer(
            prediction,
            context=serializer_context_data(user=request.user),
        )
        return Response(response_serializer.data)


class CategoryPredictionFeedbackCreateView(generics.CreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CategoryPredictionFeedbackCreateSerializer

    @extend_schema(
        tags=["ML"],
        request=CategoryPredictionFeedbackCreateSerializer,
        responses={status.HTTP_201_CREATED: CategoryPredictionFeedbackResponseSerializer},
    )
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        feedback = serializer.save()
        response_serializer = CategoryPredictionFeedbackResponseSerializer(
            feedback,
            context=serializer_context_data(user=request.user),
        )
        headers = self.get_success_headers(response_serializer.data)
        return Response(
            response_serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers,
        )
