from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _

from .managers import UserManager


class User(AbstractUser):
    email = models.EmailField(_("email address"), unique=True)

    objects = UserManager()
    REQUIRED_FIELDS: list[str] = []

    def save(self, *args, **kwargs) -> None:
        if self.email:
            normalized_email = type(self).objects.normalize_email(self.email).lower()
            self.email = normalized_email
            self.username = normalized_email

        super().save(*args, **kwargs)

    def __str__(self) -> str:
        return self.email or self.username

    class Meta:
        verbose_name = "user"
        verbose_name_plural = "users"
