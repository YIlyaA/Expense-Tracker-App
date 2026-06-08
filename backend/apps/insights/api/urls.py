from django.urls import path

from .views import DashboardView, GeneratedInsightsView, StatisticsView

urlpatterns = [
    path("dashboard/", DashboardView.as_view(), name="dashboard-summary"),
    path("insights/", GeneratedInsightsView.as_view(), name="generated-insights"),
    path("statistics/", StatisticsView.as_view(), name="statistics-summary"),
]
