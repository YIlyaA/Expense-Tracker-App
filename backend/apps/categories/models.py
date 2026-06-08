from django.core.validators import RegexValidator
from django.db import models

hex_color_validator = RegexValidator(
    regex=r"^#[0-9A-F]{6}$",
    message="Color must be an uppercase hex value such as #EF4444.",
)


class Category(models.Model):
    code = models.SlugField(max_length=64, unique=True)
    default_label = models.CharField(max_length=100)
    icon_key = models.CharField(max_length=50)
    color = models.CharField(max_length=7, validators=[hex_color_validator])
    sort_order = models.PositiveSmallIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("sort_order", "code")
        verbose_name = "category"
        verbose_name_plural = "categories"

    def save(self, *args, **kwargs) -> None:
        self.code = self.code.lower()
        super().save(*args, **kwargs)

    def __str__(self) -> str:
        return self.default_label
