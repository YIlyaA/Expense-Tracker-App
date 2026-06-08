from __future__ import annotations

import random
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand, CommandError
from django.db import transaction as db_transaction
from django.utils import timezone

from apps.categories.models import Category
from apps.categories.services import sync_default_categories
from apps.common.enums import CurrencyCode, ExpenseCategoryCode
from apps.preferences.models import UserSettings
from apps.transactions.models import Transaction
from apps.transactions.services import calculate_base_amount

User = get_user_model()

DEFAULT_EMAIL = "demo@example.com"
DEFAULT_PASSWORD = "demo12345"
DEFAULT_MONTHS = 6
DEFAULT_PER_MONTH = 50


@dataclass(frozen=True)
class CategoryProfile:
    code: str
    weight: int
    amount_range: tuple[Decimal, Decimal]
    currency_weights: tuple[tuple[str, int], ...]
    descriptions: tuple[str, ...]
    weekday_bias: tuple[int, ...] = tuple(range(7))


PROFILES: tuple[CategoryProfile, ...] = (
    CategoryProfile(
        code=ExpenseCategoryCode.FOOD.value,
        weight=30,
        amount_range=(Decimal("8.00"), Decimal("85.00")),
        currency_weights=(("PLN", 8), ("EUR", 1), ("USD", 1)),
        descriptions=(
            "Lunch",
            "Groceries Biedronka",
            "Coffee",
            "Dinner",
            "Bakery",
            "Lidl run",
            "Sushi takeaway",
            "Restaurant bill",
        ),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.TRANSPORT.value,
        weight=15,
        amount_range=(Decimal("3.40"), Decimal("180.00")),
        currency_weights=(("PLN", 9), ("EUR", 1)),
        descriptions=(
            "Tram ticket",
            "Uber",
            "Bolt ride",
            "Train PKP",
            "Fuel Orlen",
            "Bus 24h pass",
            "Taxi",
        ),
        weekday_bias=(0, 1, 2, 3, 4),  # Mon-Fri
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.PHONE.value,
        weight=3,
        amount_range=(Decimal("25.00"), Decimal("60.00")),
        currency_weights=(("PLN", 1),),
        descriptions=("Mobile top-up", "Play monthly", "Orange bill"),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.SPORT.value,
        weight=5,
        amount_range=(Decimal("15.00"), Decimal("250.00")),
        currency_weights=(("PLN", 4), ("EUR", 1)),
        descriptions=(
            "Gym day pass",
            "Tennis court",
            "Pool entry",
            "Running shoes",
            "Yoga class",
        ),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.HOUSEHOLD.value,
        weight=8,
        amount_range=(Decimal("12.00"), Decimal("420.00")),
        currency_weights=(("PLN", 1),),
        descriptions=(
            "Electricity bill",
            "Internet UPC",
            "Cleaning supplies",
            "IKEA",
            "Furniture",
            "Rent share",
        ),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.HEALTH.value,
        weight=4,
        amount_range=(Decimal("18.00"), Decimal("320.00")),
        currency_weights=(("PLN", 4), ("EUR", 1)),
        descriptions=("Pharmacy", "Dentist", "Vitamins", "Doctor visit", "Lab tests"),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.DOCUMENTS.value,
        weight=2,
        amount_range=(Decimal("20.00"), Decimal("150.00")),
        currency_weights=(("PLN", 1),),
        descriptions=("Passport fee", "Notary", "Translation", "ID renewal"),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.CLOTHES_ITEMS.value,
        weight=7,
        amount_range=(Decimal("25.00"), Decimal("450.00")),
        currency_weights=(("PLN", 6), ("EUR", 2), ("USD", 1)),
        descriptions=("Zara", "H&M", "Sneakers", "Jacket", "T-shirts", "Amazon order"),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.SUBSCRIPTIONS_EDUCATION.value,
        weight=4,
        amount_range=(Decimal("19.00"), Decimal("75.00")),
        currency_weights=(("PLN", 4), ("USD", 3), ("EUR", 1)),
        descriptions=(
            "Netflix",
            "Spotify",
            "Udemy course",
            "Notion",
            "Coursera",
            "Audible",
        ),
    ),
    CategoryProfile(
        code=ExpenseCategoryCode.OTHER.value,
        weight=3,
        amount_range=(Decimal("10.00"), Decimal("200.00")),
        currency_weights=(("PLN", 1),),
        descriptions=("Misc", "Gift", "Charity", "Cash withdrawal fee"),
    ),
)


class Command(BaseCommand):
    help = "Seed the database with a demo user and realistic expense history."

    def add_arguments(self, parser) -> None:
        parser.add_argument(
            "--email",
            default=DEFAULT_EMAIL,
            help=f"Target user email (default: {DEFAULT_EMAIL}). Created if missing.",
        )
        parser.add_argument(
            "--password",
            default=DEFAULT_PASSWORD,
            help=(
                "Password to set for newly created demo users. Ignored if the user "
                f"already exists. Default: {DEFAULT_PASSWORD}."
            ),
        )
        parser.add_argument(
            "--months",
            type=int,
            default=DEFAULT_MONTHS,
            help=f"Number of months of history to generate (default: {DEFAULT_MONTHS}).",
        )
        parser.add_argument(
            "--per-month",
            type=int,
            default=DEFAULT_PER_MONTH,
            help=(
                "Approximate number of transactions per month "
                f"(default: {DEFAULT_PER_MONTH}, ~{DEFAULT_MONTHS * DEFAULT_PER_MONTH} total)."
            ),
        )
        parser.add_argument(
            "--clear",
            action="store_true",
            help="Hard-delete the target user's existing transactions before seeding.",
        )
        parser.add_argument(
            "--seed",
            type=int,
            default=42,
            help="Random seed for reproducibility (default: 42).",
        )

    def handle(self, *args, **options) -> None:
        email: str = options["email"].strip().lower()
        password: str = options["password"]
        months: int = options["months"]
        per_month: int = options["per_month"]
        clear: bool = options["clear"]
        seed: int = options["seed"]

        if months <= 0 or per_month <= 0:
            raise CommandError("--months and --per-month must be positive integers.")

        random.seed(seed)

        sync_default_categories()

        with db_transaction.atomic():
            user, created_user = self._get_or_create_user(email, password)
            self._ensure_settings(user)

            if clear:
                deleted, _ = Transaction.objects.filter(user=user).delete()
                self.stdout.write(self.style.WARNING(f"Deleted {deleted} existing transactions for {email}."))

            categories = self._load_categories()
            created_count = self._generate_history(
                user=user,
                categories=categories,
                months=months,
                per_month=per_month,
            )

        msg_user = "Created new user" if created_user else "Reusing existing user"
        self.stdout.write(self.style.SUCCESS(f"{msg_user}: {email}"))
        if created_user:
            self.stdout.write(self.style.SUCCESS(f"Password: {password}"))
        self.stdout.write(
            self.style.SUCCESS(
                f"Seeded {created_count} transactions across {months} months "
                f"(~{per_month}/month) for {email}."
            )
        )

    def _get_or_create_user(self, email: str, password: str) -> tuple[User, bool]:
        user = User.objects.filter(email=email).first()
        if user is not None:
            return user, False
        user = User.objects.create_user(email=email, password=password)
        return user, True

    def _ensure_settings(self, user: User) -> None:
        UserSettings.objects.get_or_create(user=user)

    def _load_categories(self) -> dict[str, Category]:
        categories = {c.code: c for c in Category.objects.all()}
        missing = [p.code for p in PROFILES if p.code not in categories]
        if missing:
            raise CommandError(
                "Missing system categories after sync: "
                + ", ".join(missing)
                + ". Run migrations first."
            )
        return categories

    def _generate_history(
        self,
        *,
        user: User,
        categories: dict[str, Category],
        months: int,
        per_month: int,
    ) -> int:
        today = timezone.localdate()
        start_month = _month_floor(today)
        for _ in range(months - 1):
            start_month = _prev_month(start_month)

        weighted_profiles = _expand_by_weight(PROFILES)
        rows: list[Transaction] = []

        cursor = start_month
        while cursor <= today:
            month_end = min(_month_last_day(cursor), today)
            day_count = (month_end - cursor).days + 1
            n_for_month = max(1, int(per_month * (day_count / 30)))

            for _ in range(n_for_month):
                profile = random.choice(weighted_profiles)
                tx_date = _random_date_in(cursor, month_end, profile.weekday_bias)
                currency = _pick_weighted(profile.currency_weights)
                amount = _random_amount(profile.amount_range)
                description = random.choice(profile.descriptions)

                base_amount = calculate_base_amount(
                    original_amount=amount,
                    original_currency=currency,
                )
                rows.append(
                    Transaction(
                        user=user,
                        category=categories[profile.code],
                        description=description,
                        original_amount=amount,
                        original_currency=currency,
                        base_amount=base_amount,
                        transaction_date=tx_date,
                    )
                )

            subs_cat = categories[ExpenseCategoryCode.SUBSCRIPTIONS_EDUCATION.value]
            recurring_day = min(5, day_count)
            recurring_date = cursor.replace(day=recurring_day)
            if recurring_date <= today:
                rows.append(
                    Transaction(
                        user=user,
                        category=subs_cat,
                        description="Netflix",
                        original_amount=Decimal("43.00"),
                        original_currency="PLN",
                        base_amount=calculate_base_amount(
                            original_amount=Decimal("43.00"),
                            original_currency="PLN",
                        ),
                        transaction_date=recurring_date,
                    )
                )

            cursor = _next_month(cursor)

        Transaction.objects.bulk_create(rows, batch_size=500)
        return len(rows)


def _month_floor(d: date) -> date:
    return d.replace(day=1)


def _month_last_day(first_of_month: date) -> date:
    nxt = _next_month(first_of_month)
    return nxt - timedelta(days=1)


def _next_month(first_of_month: date) -> date:
    year, month = first_of_month.year, first_of_month.month
    if month == 12:
        return date(year + 1, 1, 1)
    return date(year, month + 1, 1)


def _prev_month(first_of_month: date) -> date:
    year, month = first_of_month.year, first_of_month.month
    if month == 1:
        return date(year - 1, 12, 1)
    return date(year, month - 1, 1)


def _expand_by_weight(profiles: tuple[CategoryProfile, ...]) -> list[CategoryProfile]:
    expanded: list[CategoryProfile] = []
    for profile in profiles:
        expanded.extend([profile] * profile.weight)
    return expanded


def _pick_weighted(weights: tuple[tuple[str, int], ...]) -> str:
    pool: list[str] = []
    for value, weight in weights:
        pool.extend([value] * weight)
    return random.choice(pool)


def _random_amount(amount_range: tuple[Decimal, Decimal]) -> Decimal:
    low, high = amount_range
    span = high - low
    raw = low + (Decimal(random.random()) * span)
    return raw.quantize(Decimal("0.01"))


def _random_date_in(
    period_start: date,
    period_end: date,
    weekday_bias: tuple[int, ...],
) -> date:
    span_days = (period_end - period_start).days
    if span_days <= 0:
        return period_start
    for _ in range(8):
        candidate = period_start + timedelta(days=random.randint(0, span_days))
        if candidate.weekday() in weekday_bias:
            return candidate
    return period_start + timedelta(days=random.randint(0, span_days))
