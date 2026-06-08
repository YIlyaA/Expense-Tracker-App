from django.contrib.auth.models import update_last_login
from rest_framework_simplejwt.tokens import RefreshToken

from apps.users.models import User


def issue_token_pair(user: User) -> dict[str, str]:
    refresh = RefreshToken.for_user(user)
    update_last_login(sender=None, user=user)

    return {
        "access": str(refresh.access_token),
        "refresh": str(refresh),
    }
