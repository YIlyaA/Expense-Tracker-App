from django.contrib import admin

from .models import Category


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("code", "default_label", "sort_order", "is_active")
    list_filter = ("is_active",)
    search_fields = ("code", "default_label")
    ordering = ("sort_order", "code")
