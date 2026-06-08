from drf_spectacular.utils import extend_schema
from rest_framework import generics, permissions, status
from rest_framework.response import Response

from apps.users.api.serializers import (
    AuthResponseSerializer,
    LoginSerializer,
    RefreshSerializer,
    RegisterSerializer,
    TokenRefreshResponseSerializer,
    UserSerializer,
)
from apps.users.models import User
from apps.users.services import issue_token_pair


class RegisterView(generics.GenericAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]
    authentication_classes: list[type] = []

    @extend_schema(
        tags=["Auth"],
        request=RegisterSerializer,
        responses={status.HTTP_201_CREATED: AuthResponseSerializer},
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        response_serializer = AuthResponseSerializer(
            {
                "user": user,
                "tokens": issue_token_pair(user),
            }
        )
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)


class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [permissions.AllowAny]
    authentication_classes: list[type] = []

    @extend_schema(
        tags=["Auth"],
        request=LoginSerializer,
        responses={status.HTTP_200_OK: AuthResponseSerializer},
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        response_serializer = AuthResponseSerializer(
            {
                "user": user,
                "tokens": issue_token_pair(user),
            }
        )
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class RefreshView(generics.GenericAPIView):
    serializer_class = RefreshSerializer
    permission_classes = [permissions.AllowAny]
    authentication_classes: list[type] = []

    @extend_schema(
        tags=["Auth"],
        request=RefreshSerializer,
        responses={status.HTTP_200_OK: TokenRefreshResponseSerializer},
    )
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        response_serializer = TokenRefreshResponseSerializer(serializer.validated_data)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class MeView(generics.RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(tags=["Auth"])
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_object(self) -> User:
        return self.request.user
