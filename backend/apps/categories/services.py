from django.db import DEFAULT_DB_ALIAS, transaction

from apps.categories.defaults import DEFAULT_CATEGORY_DEFINITIONS
from apps.categories.models import Category


def sync_default_categories(*, using: str = DEFAULT_DB_ALIAS) -> None:
    queryset = Category.objects.using(using)

    with transaction.atomic(using=using):
        for definition in DEFAULT_CATEGORY_DEFINITIONS:
            category, created = queryset.get_or_create(
                code=definition.code,
                defaults={
                    "default_label": definition.default_label,
                    "icon_key": definition.icon_key,
                    "color": definition.color,
                    "sort_order": definition.sort_order,
                    "is_active": definition.is_active,
                },
            )

            if created:
                continue

            updated_fields: list[str] = []
            defaults = {
                "default_label": definition.default_label,
                "icon_key": definition.icon_key,
                "color": definition.color,
                "sort_order": definition.sort_order,
            }

            for field_name, value in defaults.items():
                if getattr(category, field_name) != value:
                    setattr(category, field_name, value)
                    updated_fields.append(field_name)

            if updated_fields:
                category.save(update_fields=updated_fields, using=using)
