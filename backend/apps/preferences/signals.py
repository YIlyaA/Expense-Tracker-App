from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.preferences.models import UserSettings
from apps.users.models import User


@receiver(post_save, sender=User)
def create_user_settings(sender, instance: User, created: bool, **kwargs) -> None:
    if created:
        UserSettings.objects.get_or_create(user=instance)
