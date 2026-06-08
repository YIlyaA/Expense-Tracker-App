from decimal import Decimal

from rest_framework import serializers

from apps.categories.api.fields import ActiveCategoryCodeField
from apps.categories.api.serializers import CategorySerializer
from apps.transactions.models import Transaction
from apps.transactions.services import (
    BaseAmountOverflowError,
    calculate_base_amount,
    convert_base_amount_to_display,
)


class TransactionSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_code = ActiveCategoryCodeField(source="category")
    display_amount = serializers.SerializerMethodField()
    display_currency = serializers.SerializerMethodField()

    class Meta:
        model = Transaction
        fields = (
            "id",
            "category",
            "category_code",
            "description",
            "original_amount",
            "original_currency",
            "base_amount",
            "base_currency",
            "display_amount",
            "display_currency",
            "transaction_date",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "category",
            "base_amount",
            "base_currency",
            "display_amount",
            "display_currency",
            "created_at",
            "updated_at",
        )

    def validate_description(self, value: str) -> str:
        return value.strip()

    def validate_original_amount(self, value: Decimal) -> Decimal:
        if value <= 0:
            raise serializers.ValidationError("Amount must be greater than zero.")

        return value

    def validate(self, attrs: dict[str, object]) -> dict[str, object]:
        amount = attrs.get("original_amount")
        currency = attrs.get("original_currency")
        if amount is not None and currency is not None:
            try:
                calculate_base_amount(
                    original_amount=amount, original_currency=currency,
                )
            except BaseAmountOverflowError as exc:
                raise serializers.ValidationError(
                    {"original_amount": str(exc)},
                ) from exc
        return attrs

    def get_display_amount(self, obj: Transaction) -> str:
        display_currency = self.context.get("display_currency", obj.base_currency)
        return str(
            convert_base_amount_to_display(
                base_amount=obj.base_amount,
                display_currency=display_currency,
            )
        )

    def get_display_currency(self, obj: Transaction) -> str:
        return self.context.get("display_currency", obj.base_currency)

    def create(self, validated_data: dict[str, object]) -> Transaction:
        original_amount = validated_data["original_amount"]
        original_currency = validated_data["original_currency"]

        return Transaction.objects.create(
            user=self.context["request"].user,
            base_amount=calculate_base_amount(
                original_amount=original_amount,
                original_currency=original_currency,
            ),
            **validated_data,
        )

    def update(self, instance: Transaction, validated_data: dict[str, object]) -> Transaction:
        category = validated_data.pop("category", None)

        if category is not None:
            instance.category = category

        original_amount = validated_data.get("original_amount", instance.original_amount)
        original_currency = validated_data.get("original_currency", instance.original_currency)

        for field_name, value in validated_data.items():
            setattr(instance, field_name, value)

        instance.base_amount = calculate_base_amount(
            original_amount=original_amount,
            original_currency=original_currency,
        )
        instance.base_currency = Transaction.base_currency.field.default
        instance.save()
        return instance
