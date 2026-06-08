from django.db.models.signals import post_migrate
from django.dispatch import receiver

from .apps import CurrencyConfig
from .services import seed_rates_if_missing


@receiver(post_migrate, sender=CurrencyConfig)
def seed_exchange_rates(sender, **kwargs) -> None:
    seed_rates_if_missing()
