from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from decimal import ROUND_HALF_UP, Decimal
from typing import Protocol

from django.db.models import Count

from apps.categories.models import Category
from apps.ml.enums import PredictionStatus, PredictionStrategy
from apps.ml.keywords import CATEGORY_KEYWORDS
from apps.ml.models import CategoryPredictionFeedback

CONFIDENCE_QUANTIZE_EXPONENT = Decimal("0.01")
ZERO_CONFIDENCE = Decimal("0.00")
PREDICTION_CONFIDENCE_THRESHOLD = Decimal("0.78")
PREDICTION_MARGIN_THRESHOLD = Decimal("0.35")
CATEGORY_CLASSIFIER_VERSION = "hybrid_category_classifier_v1"
MAX_CANDIDATES = 3

NON_WORD_RE = re.compile(r"[^\w\s]+", flags=re.UNICODE)
WHITESPACE_RE = re.compile(r"\s+")


@dataclass(frozen=True, slots=True)
class PredictionCandidate:
    category: Category
    score: Decimal


@dataclass(frozen=True, slots=True)
class PredictionResult:
    input_text: str
    normalized_input_text: str
    status: str
    confidence: Decimal
    predicted_category: Category | None
    candidates: tuple[PredictionCandidate, ...]
    classifier_version: str
    strategy: str


class CategoryClassifier(Protocol):
    def predict(
        self,
        *,
        user,
        input_text: str,
        normalized_input_text: str,
        categories_by_code: dict[str, Category],
        candidate_limit: int,
    ) -> PredictionResult | None:
        ...


class FeedbackMemoryCategoryClassifier:
    def predict(
        self,
        *,
        user,
        input_text: str,
        normalized_input_text: str,
        categories_by_code: dict[str, Category],
        candidate_limit: int,
    ) -> PredictionResult | None:
        rows = list(
            CategoryPredictionFeedback.objects.filter(
                user=user,
                normalized_input_text=normalized_input_text,
                selected_category__is_active=True,
            )
            .values("selected_category__code")
            .annotate(example_count=Count("id"))
            .order_by("-example_count", "selected_category__code")
        )
        if not rows:
            return None

        total_examples = sum(row["example_count"] for row in rows)
        candidates: list[PredictionCandidate] = []
        for row in rows[:candidate_limit]:
            category = categories_by_code.get(row["selected_category__code"])
            if category is None:
                continue

            candidates.append(
                PredictionCandidate(
                    category=category,
                    score=quantize_confidence(
                        Decimal(row["example_count"]) / Decimal(total_examples)
                    ),
                )
            )

        if not candidates:
            return None

        top_row = rows[0]
        top_category = categories_by_code.get(top_row["selected_category__code"])
        if top_category is None:
            return None

        top_count = top_row["example_count"]
        second_count = rows[1]["example_count"] if len(rows) > 1 else 0
        top_share = Decimal(top_count) / Decimal(total_examples)

        if second_count == 0:
            status = PredictionStatus.PREDICTED.value
            confidence = quantize_confidence(
                min(
                    Decimal("0.98"),
                    Decimal("0.90") + (Decimal(min(top_count, 4)) * Decimal("0.02")),
                )
            )
        elif top_share >= Decimal("0.75"):
            status = PredictionStatus.PREDICTED.value
            confidence = quantize_confidence(
                min(Decimal("0.95"), Decimal("0.75") + (top_share * Decimal("0.20")))
            )
        else:
            status = PredictionStatus.UNCERTAIN.value
            confidence = quantize_confidence(top_share)

        return PredictionResult(
            input_text=input_text,
            normalized_input_text=normalized_input_text,
            status=status,
            confidence=confidence,
            predicted_category=top_category,
            candidates=tuple(candidates),
            classifier_version=CATEGORY_CLASSIFIER_VERSION,
            strategy=PredictionStrategy.FEEDBACK_MEMORY.value,
        )


class KeywordRuleCategoryClassifier:
    def predict(
        self,
        *,
        user,
        input_text: str,
        normalized_input_text: str,
        categories_by_code: dict[str, Category],
        candidate_limit: int,
    ) -> PredictionResult:
        del user
        token_set = set(normalized_input_text.split())
        raw_scores: dict[str, Decimal] = {}

        for category_code, keywords in CATEGORY_KEYWORDS.items():
            if category_code not in categories_by_code:
                continue

            score = ZERO_CONFIDENCE
            for keyword in keywords:
                normalized_term = normalize_prediction_text(keyword.term)
                if not normalized_term:
                    continue

                if " " in normalized_term:
                    if normalized_term in normalized_input_text:
                        score += keyword.weight
                elif normalized_term in token_set:
                    score += keyword.weight

            if score > ZERO_CONFIDENCE:
                raw_scores[category_code] = score

        if not raw_scores:
            return build_no_match_prediction(input_text=input_text)

        total_score = sum(raw_scores.values(), start=ZERO_CONFIDENCE)
        ordered_scores = sorted(
            raw_scores.items(),
            key=lambda item: (
                -item[1],
                categories_by_code[item[0]].sort_order,
                item[0],
            ),
        )
        top_code, top_score = ordered_scores[0]
        second_score = ordered_scores[1][1] if len(ordered_scores) > 1 else ZERO_CONFIDENCE
        margin = top_score - second_score
        confidence = quantize_confidence(
            min(
                Decimal("0.99"),
                ((top_score / total_score) * Decimal("0.60"))
                + min(top_score / Decimal("4.00"), Decimal("0.25")),
            )
        )
        status = (
            PredictionStatus.PREDICTED.value
            if confidence >= PREDICTION_CONFIDENCE_THRESHOLD
            and (second_score == ZERO_CONFIDENCE or margin >= PREDICTION_MARGIN_THRESHOLD)
            else PredictionStatus.UNCERTAIN.value
        )
        candidates = tuple(
            PredictionCandidate(
                category=categories_by_code[category_code],
                score=quantize_confidence(score / total_score),
            )
            for category_code, score in ordered_scores[:candidate_limit]
        )
        return PredictionResult(
            input_text=input_text,
            normalized_input_text=normalized_input_text,
            status=status,
            confidence=confidence,
            predicted_category=categories_by_code[top_code],
            candidates=candidates,
            classifier_version=CATEGORY_CLASSIFIER_VERSION,
            strategy=PredictionStrategy.KEYWORD_RULES.value,
        )


class HybridCategoryClassifier:
    def __init__(
        self,
        *,
        feedback_classifier: CategoryClassifier | None = None,
        keyword_classifier: CategoryClassifier | None = None,
    ) -> None:
        self.feedback_classifier = feedback_classifier or FeedbackMemoryCategoryClassifier()
        self.keyword_classifier = keyword_classifier or KeywordRuleCategoryClassifier()

    def predict(
        self,
        *,
        user,
        input_text: str,
        candidate_limit: int = MAX_CANDIDATES,
    ) -> PredictionResult:
        normalized_input_text = normalize_prediction_text(input_text)
        if not normalized_input_text:
            return build_no_match_prediction(input_text=input_text)

        categories_by_code = {
            category.code: category
            for category in Category.objects.filter(is_active=True).order_by("sort_order", "code")
        }
        if not categories_by_code:
            return build_no_match_prediction(input_text=input_text)

        feedback_prediction = self.feedback_classifier.predict(
            user=user,
            input_text=input_text,
            normalized_input_text=normalized_input_text,
            categories_by_code=categories_by_code,
            candidate_limit=candidate_limit,
        )
        if feedback_prediction is not None:
            return feedback_prediction

        return self.keyword_classifier.predict(
            user=user,
            input_text=input_text,
            normalized_input_text=normalized_input_text,
            categories_by_code=categories_by_code,
            candidate_limit=candidate_limit,
        )


def normalize_prediction_text(value: str) -> str:
    normalized = unicodedata.normalize("NFKC", value).lower()
    normalized = NON_WORD_RE.sub(" ", normalized)
    normalized = WHITESPACE_RE.sub(" ", normalized)
    return normalized.strip()


def quantize_confidence(value: Decimal) -> Decimal:
    return value.quantize(CONFIDENCE_QUANTIZE_EXPONENT, rounding=ROUND_HALF_UP)


def build_no_match_prediction(*, input_text: str) -> PredictionResult:
    return PredictionResult(
        input_text=input_text,
        normalized_input_text=normalize_prediction_text(input_text),
        status=PredictionStatus.NO_MATCH.value,
        confidence=ZERO_CONFIDENCE,
        predicted_category=None,
        candidates=(),
        classifier_version=CATEGORY_CLASSIFIER_VERSION,
        strategy=PredictionStrategy.KEYWORD_RULES.value,
    )


def get_category_classifier() -> HybridCategoryClassifier:
    return HybridCategoryClassifier()


def predict_category_for_text(*, user, input_text: str) -> PredictionResult:
    return get_category_classifier().predict(user=user, input_text=input_text.strip())


def create_category_prediction_feedback(
    *,
    user,
    input_text: str,
    selected_category: Category,
    predicted_category: Category | None = None,
    predicted_confidence: Decimal | None = None,
    predicted_status: str = "",
    prediction_strategy: str = "",
    classifier_version: str = "",
    transaction=None,
) -> CategoryPredictionFeedback:
    stripped_input_text = input_text.strip()
    return CategoryPredictionFeedback.objects.create(
        user=user,
        transaction=transaction,
        input_text=stripped_input_text,
        normalized_input_text=normalize_prediction_text(stripped_input_text),
        predicted_category=predicted_category,
        predicted_confidence=predicted_confidence,
        predicted_status=predicted_status,
        prediction_strategy=prediction_strategy,
        classifier_version=classifier_version,
        selected_category=selected_category,
        was_corrected=(
            predicted_category is not None and predicted_category.code != selected_category.code
        ),
    )
