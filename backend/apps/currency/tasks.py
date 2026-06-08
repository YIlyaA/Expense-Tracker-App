from __future__ import annotations

import logging

from celery import shared_task

from .services import refresh_rates_from_provider

logger = logging.getLogger(__name__)


@shared_task(
    name="apps.currency.refresh_exchange_rates",
    bind=True,
    autoretry_for=(Exception,),
    retry_backoff=True,
    retry_backoff_max=600,
    retry_jitter=True,
    max_retries=3,
    acks_late=True,
)
def refresh_exchange_rates_task(self) -> dict:
    try:
        result = refresh_rates_from_provider()
    except Exception:
        logger.exception("Exchange-rate refresh failed; will retry.")
        raise
    return {
        "source": result.source_name,
        "updated_currencies": result.updated_currencies,
        "updated_count": result.updated_count,
    }
