from __future__ import annotations

from enum import StrEnum


class PredictionStatus(StrEnum):
    PREDICTED = "predicted"
    UNCERTAIN = "uncertain"
    NO_MATCH = "no_match"

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(member.value for member in cls)


class PredictionStrategy(StrEnum):
    FEEDBACK_MEMORY = "feedback_memory_v1"
    KEYWORD_RULES = "keyword_rules_v1"

    @classmethod
    def values(cls) -> tuple[str, ...]:
        return tuple(member.value for member in cls)
