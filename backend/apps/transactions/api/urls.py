from django.urls import path

from .views import TransactionDetailView, TransactionListCreateView

urlpatterns = [
    path("", TransactionListCreateView.as_view(), name="transactions-list"),
    path("<int:pk>/", TransactionDetailView.as_view(), name="transactions-detail"),
]
