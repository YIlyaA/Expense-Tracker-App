from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from apps.categories.models import Category
from apps.ml.enums import PredictionStatus


class CategoryPredictionFeedback(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="category_prediction_feedback",
    )
    transaction = models.ForeignKey(
        "transactions.Transaction",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="category_prediction_feedback",
    )
    input_text = models.CharField(max_length=255)
    normalized_input_text = models.CharField(max_length=255)
    predicted_category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="predicted_feedback_examples",
    )
    predicted_confidence = models.DecimalField(
        max_digits=4,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(1)],
    )
    predicted_status = models.CharField(
        max_length=16,
        choices=tuple((value, value) for value in PredictionStatus.values()),
        blank=True,
        default="",
    )
    prediction_strategy = models.CharField(max_length=50, blank=True, default="")
    classifier_version = models.CharField(max_length=50, blank=True, default="")
    selected_category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name="selected_feedback_examples",
    )
    was_corrected = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at", "-id")
        indexes = [
            models.Index(fields=("user", "normalized_input_text")),
            models.Index(fields=("user", "created_at")),
        ]
        verbose_name = "category prediction feedback"
        verbose_name_plural = "category prediction feedback"

    def __str__(self) -> str:
        return f"{self.user.email}: {self.selected_category.code}"
