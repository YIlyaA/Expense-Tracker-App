from django.urls import path

from .views import UserSettingsView

urlpatterns = [
    path("me/", UserSettingsView.as_view(), name="settings-me"),
]
