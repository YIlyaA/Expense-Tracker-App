from rest_framework import serializers

from apps.categories.defaults import get_category_definition
from apps.categories.models import Category
from apps.common.constants import DEFAULT_LANGUAGE_CODE


class CategorySerializer(serializers.ModelSerializer):
    label = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = (
            "code",
            "default_label",
            "label",
            "icon_key",
            "color",
            "sort_order",
            "is_active",
        )
        read_only_fields = fields

    def get_label(self, obj: Category) -> str:
        language_code = self.context.get("category_language", DEFAULT_LANGUAGE_CODE)
        definition = get_category_definition(obj.code)

        if definition is None:
            return obj.default_label

        return definition.label_for(language_code)
