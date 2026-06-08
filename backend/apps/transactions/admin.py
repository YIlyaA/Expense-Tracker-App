from django.contrib import admin

from .models import Transaction


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "category",
        "original_amount",
        "original_currency",
        "base_amount",
        "transaction_date",
    )
    list_filter = ("original_currency", "base_currency", "category")
    search_fields = ("user__email", "description", "category__code")
    ordering = ("-transaction_date", "-created_at", "-id")
