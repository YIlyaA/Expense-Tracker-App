from django.urls import path

from .views import CategoryPredictionFeedbackCreateView, CategoryPredictionView

urlpatterns = [
    path(
        "category-predictions/",
        CategoryPredictionView.as_view(),
        name="category-predictions",
    ),
    path(
        "category-feedback/",
        CategoryPredictionFeedbackCreateView.as_view(),
        name="category-prediction-feedback",
    ),
]
