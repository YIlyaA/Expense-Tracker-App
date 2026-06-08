from decimal import Decimal

from rest_framework import serializers

from apps.categories.api.fields import ActiveCategoryCodeField
from apps.categories.api.serializers import CategorySerializer
from apps.ml.enums import PredictionStatus
from apps.ml.models import CategoryPredictionFeedback
from apps.ml.services import create_category_prediction_feedback, predict_category_for_text
from apps.transactions.models import Transaction


class PredictionCandidateSerializer(serializers.Serializer):
    category_code = serializers.CharField(source="category.code")
    category = CategorySerializer()
    score = serializers.DecimalField(max_digits=4, decimal_places=2)


class CategoryPredictionResponseSerializer(serializers.Serializer):
    input_text = serializers.CharField()
    status = serializers.ChoiceField(choices=PredictionStatus.values())
    confidence = serializers.DecimalField(max_digits=4, decimal_places=2)
    predicted_category_code = serializers.SerializerMethodField()
    predicted_category = serializers.SerializerMethodField()
    candidates = PredictionCandidateSerializer(many=True)
    classifier_version = serializers.CharField()
    strategy = serializers.CharField()

    def get_predicted_category_code(self, obj) -> str | None:
        predicted_category = obj.predicted_category
        if predicted_category is None:
            return None

        return predicted_category.code

    def get_predicted_category(self, obj):
        predicted_category = obj.predicted_category
        if predicted_category is None:
            return None

        return CategorySerializer(predicted_category, context=self.context).data


class CategoryPredictionRequestSerializer(serializers.Serializer):
    input_text = serializers.CharField(max_length=255)

    def validate_input_text(self, value: str) -> str:
        stripped_value = value.strip()
        if not stripped_value:
            raise serializers.ValidationError("Input text must not be blank.")

        return stripped_value

    def create_prediction(self):
        return predict_category_for_text(
            user=self.context["request"].user,
            input_text=self.validated_data["input_text"],
        )


class CategoryPredictionFeedbackResponseSerializer(serializers.ModelSerializer):
    selected_category_code = serializers.CharField(source="selected_category.code")
    selected_category = CategorySerializer(read_only=True)
    predicted_category_code = serializers.SerializerMethodField()
    transaction_id = serializers.SerializerMethodField()

    class Meta:
        model = CategoryPredictionFeedback
        fields = (
            "id",
            "input_text",
            "selected_category_code",
            "selected_category",
            "predicted_category_code",
            "predicted_status",
            "predicted_confidence",
            "prediction_strategy",
            "classifier_version",
            "was_corrected",
            "transaction_id",
            "created_at",
        )
        read_only_fields = fields

    def get_predicted_category_code(self, obj: CategoryPredictionFeedback) -> str | None:
        if obj.predicted_category is None:
            return None

        return obj.predicted_category.code

    def get_transaction_id(self, obj: CategoryPredictionFeedback) -> int | None:
        if obj.transaction_id is None:
            return None

        return obj.transaction_id


class CategoryPredictionFeedbackCreateSerializer(serializers.Serializer):
    input_text = serializers.CharField(max_length=255)
    selected_category_code = ActiveCategoryCodeField(
        source="selected_category",
        does_not_exist_message="Selected category must exist and be active.",
    )
    predicted_category_code = ActiveCategoryCodeField(
        source="predicted_category",
        required=False,
        allow_null=True,
        does_not_exist_message="Predicted category must exist and be active.",
    )
    predicted_confidence = serializers.DecimalField(
        max_digits=4,
        decimal_places=2,
        required=False,
        allow_null=True,
        min_value=Decimal("0.00"),
        max_value=Decimal("1.00"),
    )
    predicted_status = serializers.ChoiceField(
        choices=PredictionStatus.values(),
        required=False,
        allow_blank=True,
    )
    prediction_strategy = serializers.CharField(required=False, allow_blank=True, max_length=50)
    classifier_version = serializers.CharField(required=False, allow_blank=True, max_length=50)
    transaction_id = serializers.IntegerField(required=False, allow_null=True)

    def validate_input_text(self, value: str) -> str:
        stripped_value = value.strip()
        if not stripped_value:
            raise serializers.ValidationError("Input text must not be blank.")

        return stripped_value

    def validate_transaction_id(self, value: int | None) -> Transaction | None:
        if value is None:
            return None

        try:
            return Transaction.objects.get(id=value, user=self.context["request"].user)
        except Transaction.DoesNotExist as exc:
            raise serializers.ValidationError(
                "Transaction must belong to the authenticated user."
            ) from exc

    def create(self, validated_data: dict[str, object]) -> CategoryPredictionFeedback:
        selected_category = validated_data["selected_category"]
        predicted_category = validated_data.get("predicted_category")
        return create_category_prediction_feedback(
            user=self.context["request"].user,
            input_text=validated_data["input_text"],
            selected_category=selected_category,
            predicted_category=predicted_category,
            predicted_confidence=validated_data.get("predicted_confidence"),
            predicted_status=validated_data.get("predicted_status", ""),
            prediction_strategy=validated_data.get("prediction_strategy", ""),
            classifier_version=validated_data.get("classifier_version", ""),
            transaction=validated_data.get("transaction_id"),
        )
