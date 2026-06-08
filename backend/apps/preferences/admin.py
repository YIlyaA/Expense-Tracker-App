from django.contrib import admin

from .models import UserSettings


@admin.register(UserSettings)
class UserSettingsAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "preferred_language",
        "preferred_currency",
    )
    search_fields = ("user__email",)
