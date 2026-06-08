from __future__ import annotations

from django.core.management.base import BaseCommand, CommandError

from apps.currency.services import refresh_rates_from_provider


class Command(BaseCommand):
    help = "Fetch latest exchange rates from the configured provider."

    def add_arguments(self, parser) -> None:
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Fetch and print rates without writing to the database.",
        )

    def handle(self, *args, **options) -> None:
        if options["dry_run"]:
            from apps.currency.providers import get_default_provider

            provider = get_default_provider()
            try:
                fetched = provider.fetch_latest()
            except Exception as exc:  # noqa: BLE001
                raise CommandError(f"Provider {provider.source_name} failed: {exc}") from exc
            for rate in fetched:
                self.stdout.write(
                    f"[dry-run] 1 {rate.currency} = {rate.rate_to_base} "
                    f"(effective {rate.effective_date}, src {rate.source})"
                )
            return

        try:
            result = refresh_rates_from_provider()
        except Exception as exc:  # noqa: BLE001
            raise CommandError(f"Refresh failed: {exc}") from exc

        for rate in result.fetched:
            self.stdout.write(
                f"1 {rate.currency} = {rate.rate_to_base} "
                f"(effective {rate.effective_date})"
            )
        self.stdout.write(
            self.style.SUCCESS(
                f"Updated {result.updated_count} currencies via {result.source_name}."
            )
        )
