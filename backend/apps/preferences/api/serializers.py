from rest_framework import serializers

from apps.preferences.models import UserSettings


class UserSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserSettings
        fields = (
            "preferred_language",
            "preferred_currency",
        )
