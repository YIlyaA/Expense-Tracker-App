from django.contrib.auth.models import UserManager as DjangoUserManager


class UserManager(DjangoUserManager):
    use_in_migrations = True

    def _create_user(
        self,
        username: str | None,
        email: str | None,
        password: str | None,
        **extra_fields,
    ):
        candidate_email = email or username

        if not candidate_email:
            raise ValueError("The given email must be set")

        normalized_email = self.normalize_email(candidate_email).lower()
        return super()._create_user(
            normalized_email,
            normalized_email,
            password,
            **extra_fields,
        )

    def create_user(
        self,
        username: str | None = None,
        email: str | None = None,
        password: str | None = None,
        **extra_fields,
    ):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(username, email, password, **extra_fields)

    def create_superuser(
        self,
        username: str | None = None,
        email: str | None = None,
        password: str | None = None,
        **extra_fields,
    ):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(username, email, password, **extra_fields)
