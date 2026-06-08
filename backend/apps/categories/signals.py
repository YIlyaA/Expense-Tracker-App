from django.apps import apps as django_apps
from django.db.models.signals import post_migrate
from django.dispatch import receiver

from apps.categories.services import sync_default_categories


@receiver(post_migrate)
def sync_seeded_categories(sender, app_config, using, **kwargs) -> None:
    category_app = django_apps.get_app_config("categories")

    if app_config != category_app:
        return

    sync_default_categories(using=using)
