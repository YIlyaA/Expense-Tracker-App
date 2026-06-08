from rest_framework import serializers

from apps.categories.models import Category


class ActiveCategoryCodeField(serializers.Field):
    default_error_messages = {
        "invalid": "Category code must be a string.",
        "does_not_exist": "Category must exist and be active.",
    }

    def __init__(
        self,
        *args,
        does_not_exist_message: str | None = None,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)
        self.does_not_exist_message = (
            does_not_exist_message or self.default_error_messages["does_not_exist"]
        )

    def to_representation(self, value: Category | None) -> str | None:
        if value is None:
            return None

        return value.code

    def to_internal_value(self, data) -> Category:
        if not isinstance(data, str):
            self.fail("invalid")

        normalized_code = data.strip().lower()
        if not normalized_code:
            self.fail("invalid")

        try:
            return Category.objects.get(code=normalized_code, is_active=True)
        except Category.DoesNotExist as exc:
            raise serializers.ValidationError(self.does_not_exist_message) from exc
