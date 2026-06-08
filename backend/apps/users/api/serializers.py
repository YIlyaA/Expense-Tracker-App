from django.contrib.auth import authenticate, password_validation
from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import serializers
from rest_framework_simplejwt.serializers import (
    TokenRefreshSerializer as SimpleJWTTokenRefreshSerializer,
)

from apps.preferences.api.serializers import UserSettingsSerializer
from apps.preferences.models import UserSettings
from apps.users.models import User


class UserSerializer(serializers.ModelSerializer):
    settings = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            "id",
            "email",
            "settings",
            "date_joined",
        )
        read_only_fields = fields

    def get_settings(self, obj: User) -> dict[str, object]:
        user_settings, _ = UserSettings.objects.get_or_create(user=obj)
        return UserSettingsSerializer(user_settings).data


class TokenPairSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField()


class TokenRefreshRequestSerializer(serializers.Serializer):
    refresh = serializers.CharField()


class TokenRefreshResponseSerializer(serializers.Serializer):
    access = serializers.CharField()
    refresh = serializers.CharField(required=False)


class AuthResponseSerializer(serializers.Serializer):
    user = UserSerializer()
    tokens = TokenPairSerializer()


class RegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(trim_whitespace=False, write_only=True)
    password_confirm = serializers.CharField(trim_whitespace=False, write_only=True)

    def validate_email(self, value: str) -> str:
        normalized_email = User.objects.normalize_email(value).lower()

        if User.objects.filter(email__iexact=normalized_email).exists():
            raise serializers.ValidationError("A user with this email already exists.")

        return normalized_email

    def validate(self, attrs: dict[str, str]) -> dict[str, str]:
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError(
                {"password_confirm": "Password confirmation does not match."}
            )

        candidate_user = User(email=attrs["email"])

        try:
            password_validation.validate_password(attrs["password"], candidate_user)
        except DjangoValidationError as exc:
            raise serializers.ValidationError({"password": list(exc.messages)}) from exc

        return attrs

    def create(self, validated_data: dict[str, str]) -> User:
        validated_data.pop("password_confirm")

        return User.objects.create_user(
            email=validated_data["email"],
            password=validated_data["password"],
        )


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(trim_whitespace=False, write_only=True)

    def validate(self, attrs: dict[str, str]) -> dict[str, str | User]:
        normalized_email = User.objects.normalize_email(attrs["email"]).lower()
        user = authenticate(
            request=self.context.get("request"),
            username=normalized_email,
            password=attrs["password"],
        )

        if user is None:
            raise serializers.ValidationError({"detail": "Invalid email or password."})

        attrs["email"] = normalized_email
        attrs["user"] = user
        return attrs


class RefreshSerializer(TokenRefreshRequestSerializer):
    def validate(self, attrs: dict[str, str]) -> dict[str, str]:
        serializer = SimpleJWTTokenRefreshSerializer(data=attrs)
        serializer.is_valid(raise_exception=True)
        return serializer.validated_data
