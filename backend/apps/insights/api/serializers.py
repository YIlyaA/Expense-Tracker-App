from rest_framework import serializers

from apps.categories.api.serializers import CategorySerializer
from apps.common.constants import SYSTEM_BASE_CURRENCY_CODE
from apps.common.enums import AppLanguage, CurrencyCode
from apps.insights.enums import InsightCode, InsightSeverity
from apps.transactions.models import Transaction
from apps.transactions.services import (
    convert_base_amount_to_display,
    get_active_conversion_source,
)


class CurrencyContextSerializer(serializers.Serializer):
    base_currency = serializers.ChoiceField(choices=CurrencyCode.values())
    display_currency = serializers.ChoiceField(choices=CurrencyCode.values())
    conversion_source = serializers.CharField()


class PeriodSerializer(serializers.Serializer):
    kind = serializers.ChoiceField(choices=("current_month", "custom"))
    date_from = serializers.DateField()
    date_to = serializers.DateField()


class InsightPeriodSerializer(serializers.Serializer):
    kind = serializers.CharField()
    date_from = serializers.DateField()
    date_to = serializers.DateField()


class AmountSummarySerializer(serializers.Serializer):
    base_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    display_amount = serializers.SerializerMethodField()

    def get_display_amount(self, obj: dict[str, object]) -> str:
        return str(
            convert_base_amount_to_display(
                base_amount=obj["base_amount"],
                display_currency=self.context["display_currency"],
            )
        )


class RecentTransactionSerializer(serializers.ModelSerializer):
    category_code = serializers.CharField(source="category.code")
    category = CategorySerializer(read_only=True)
    display_amount = serializers.SerializerMethodField()

    class Meta:
        model = Transaction
        fields = (
            "id",
            "category_code",
            "category",
            "description",
            "original_amount",
            "original_currency",
            "base_amount",
            "base_currency",
            "display_amount",
            "transaction_date",
            "created_at",
        )
        read_only_fields = fields

    def get_display_amount(self, obj: Transaction) -> str:
        return str(
            convert_base_amount_to_display(
                base_amount=obj.base_amount,
                display_currency=self.context["display_currency"],
            )
        )


class CategoryAggregateSerializer(serializers.Serializer):
    category_code = serializers.CharField(source="category.code")
    category = CategorySerializer()
    transaction_count = serializers.IntegerField()
    total_base_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_display_amount = serializers.SerializerMethodField()

    def get_total_display_amount(self, obj: dict[str, object]) -> str:
        return str(
            convert_base_amount_to_display(
                base_amount=obj["total_base_amount"],
                display_currency=self.context["display_currency"],
            )
        )


class MonthlyTotalSerializer(serializers.Serializer):
    month = serializers.CharField()
    total_base_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_display_amount = serializers.SerializerMethodField()

    def get_total_display_amount(self, obj: dict[str, object]) -> str:
        return str(
            convert_base_amount_to_display(
                base_amount=obj["total_base_amount"],
                display_currency=self.context["display_currency"],
            )
        )


class DashboardResponseSerializer(serializers.Serializer):
    currency_context = CurrencyContextSerializer()
    period = PeriodSerializer()
    current_month_total = AmountSummarySerializer()
    recent_transactions = RecentTransactionSerializer(many=True)
    top_categories = CategoryAggregateSerializer(many=True)


class StatisticsResponseSerializer(serializers.Serializer):
    currency_context = CurrencyContextSerializer()
    period = PeriodSerializer()
    total_spent = AmountSummarySerializer()
    category_breakdown = CategoryAggregateSerializer(many=True)
    monthly_totals = MonthlyTotalSerializer(many=True)


class InsightCardSerializer(serializers.Serializer):
    code = serializers.ChoiceField(choices=InsightCode.values())
    title = serializers.CharField()
    message = serializers.CharField()
    severity = serializers.ChoiceField(choices=InsightSeverity.values())
    related_category_code = serializers.CharField(allow_null=True, required=False)
    related_category = CategorySerializer(allow_null=True, required=False)
    period = InsightPeriodSerializer(allow_null=True, required=False)
    metadata = serializers.JSONField()


class InsightsResponseSerializer(serializers.Serializer):
    generator = serializers.CharField()
    message_locale = serializers.ChoiceField(choices=AppLanguage.values())
    currency_context = CurrencyContextSerializer()
    insights = InsightCardSerializer(many=True)


class StatisticsQuerySerializer(serializers.Serializer):
    date_from = serializers.DateField(required=False)
    date_to = serializers.DateField(required=False)

    def validate(self, attrs: dict[str, object]) -> dict[str, object]:
        date_from = attrs.get("date_from")
        date_to = attrs.get("date_to")

        if bool(date_from) != bool(date_to):
            raise serializers.ValidationError(
                "date_from and date_to must be provided together."
            )

        if date_from and date_to and date_from > date_to:
            raise serializers.ValidationError("date_from must be on or before date_to.")

        return attrs


def build_currency_context(*, display_currency: str) -> dict[str, str]:
    return {
        "base_currency": SYSTEM_BASE_CURRENCY_CODE,
        "display_currency": display_currency,
        "conversion_source": get_active_conversion_source(
            display_currency=display_currency,
        ),
    }
