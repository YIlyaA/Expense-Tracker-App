from django.contrib import admin

from apps.ml.models import CategoryPredictionFeedback


@admin.register(CategoryPredictionFeedback)
class CategoryPredictionFeedbackAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "selected_category",
        "predicted_category",
        "predicted_status",
        "predicted_confidence",
        "was_corrected",
        "created_at",
    )
    list_filter = (
        "selected_category",
        "predicted_category",
        "predicted_status",
        "was_corrected",
    )
    search_fields = (
        "user__email",
        "input_text",
        "normalized_input_text",
    )
    autocomplete_fields = (
        "user",
        "transaction",
        "selected_category",
        "predicted_category",
    )
