import django_filters

from apps.transactions.models import Transaction


class TransactionFilterSet(django_filters.FilterSet):
    category = django_filters.CharFilter(method="filter_category")
    date_from = django_filters.DateFilter(field_name="transaction_date", lookup_expr="gte")
    date_to = django_filters.DateFilter(field_name="transaction_date", lookup_expr="lte")

    class Meta:
        model = Transaction
        fields = ("category", "date_from", "date_to")

    def filter_category(self, queryset, name: str, value: str):
        del name
        return queryset.filter(category__code=value.strip().lower())
