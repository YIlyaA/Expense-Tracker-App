from rest_framework import serializers

from apps.categories.models import Category
from apps.common.enums import AppLanguage, CurrencyCode
from apps.preferences.models import UserSettings
from apps.transactions.models import Transaction


class SyncCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = (
            "code", "default_label", "icon_key", "color",
            "sort_order", "is_active", "updated_at",
        )
        read_only_fields = fields


class SyncTransactionSerializer(serializers.ModelSerializer):
    category_code = serializers.SlugRelatedField(
        source="category", slug_field="code", read_only=True,
    )

    class Meta:
        model = Transaction
        fields = (
            "id",
            "category_code",
            "description",
            "original_amount",
            "original_currency",
            "base_amount",
            "base_currency",
            "transaction_date",
            "created_at",
            "updated_at",
        )
        read_only_fields = fields


class SyncSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserSettings
        fields = ("preferred_language", "preferred_currency", "updated_at")
        read_only_fields = fields


class SyncPullTransactionsSerializer(serializers.Serializer):
    upserted = SyncTransactionSerializer(many=True)
    deleted_ids = serializers.ListField(child=serializers.IntegerField())


class SyncPullResponseSerializer(serializers.Serializer):
    server_timestamp = serializers.DateTimeField()
    categories = SyncCategorySerializer(many=True)
    transactions = SyncPullTransactionsSerializer()
    settings = SyncSettingsSerializer(allow_null=True)


class SyncPushTransactionCreateSerializer(serializers.Serializer):
    client_id = serializers.UUIDField()
    category_code = serializers.CharField()
    description = serializers.CharField(required=False, default="", allow_blank=True)
    original_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    original_currency = serializers.ChoiceField(choices=CurrencyCode.choices())
    transaction_date = serializers.DateField()


class SyncPushTransactionUpdateSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    category_code = serializers.CharField(required=False)
    description = serializers.CharField(required=False, allow_blank=True)
    original_amount = serializers.DecimalField(
        max_digits=12, decimal_places=2, required=False,
    )
    original_currency = serializers.ChoiceField(
        choices=CurrencyCode.choices(), required=False,
    )
    transaction_date = serializers.DateField(required=False)
    updated_at = serializers.DateTimeField()


class SyncPushTransactionDeleteSerializer(serializers.Serializer):
    id = serializers.IntegerField()


class SyncPushTransactionsSerializer(serializers.Serializer):
    created = SyncPushTransactionCreateSerializer(many=True, required=False, default=[])
    updated = SyncPushTransactionUpdateSerializer(many=True, required=False, default=[])
    deleted = SyncPushTransactionDeleteSerializer(many=True, required=False, default=[])


class SyncPushSettingsSerializer(serializers.Serializer):
    preferred_language = serializers.ChoiceField(
        choices=AppLanguage.choices(), required=False,
    )
    preferred_currency = serializers.ChoiceField(
        choices=CurrencyCode.choices(), required=False,
    )
    updated_at = serializers.DateTimeField(required=False)


class SyncPushRequestSerializer(serializers.Serializer):
    transactions = SyncPushTransactionsSerializer(required=False, default={})
    settings = SyncPushSettingsSerializer(required=False, allow_null=True, default=None)


class SyncIdMappingSerializer(serializers.Serializer):
    client_id = serializers.UUIDField()
    server_id = serializers.IntegerField()


class SyncConflictSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    server_version = SyncTransactionSerializer()


class SyncPushResponseSerializer(serializers.Serializer):
    server_timestamp = serializers.DateTimeField()
    id_mappings = SyncIdMappingSerializer(many=True)
    conflicts = SyncConflictSerializer(many=True)
    settings = SyncSettingsSerializer(allow_null=True)
