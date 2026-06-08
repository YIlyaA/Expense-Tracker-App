from django.db import transaction as db_transaction
from django.utils import timezone
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.categories.models import Category
from apps.preferences.models import UserSettings
from apps.transactions.models import Transaction
from apps.transactions.services import BaseAmountOverflowError, calculate_base_amount

from .serializers import (
    SyncCategorySerializer,
    SyncPullResponseSerializer,
    SyncPushRequestSerializer,
    SyncPushResponseSerializer,
    SyncSettingsSerializer,
    SyncTransactionSerializer,
)


class SyncPullView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=["Sync"],
        summary="Pull changes from server",
        description=(
            "Full sync (no `since`): returns all active categories, transactions, "
            "and user settings. "
            "Incremental sync (`since` ISO 8601 datetime): returns only data changed "
            "after that timestamp, plus IDs of transactions deleted since then."
        ),
        parameters=[
            OpenApiParameter(
                name="since",
                type=str,
                location=OpenApiParameter.QUERY,
                required=False,
                description="ISO 8601 datetime for incremental sync. Omit for full sync.",
            ),
        ],
        responses={200: SyncPullResponseSerializer},
    )
    def get(self, request, *args, **kwargs):
        since = request.query_params.get("since")
        since_dt = None

        if since:
            from django.utils.dateparse import parse_datetime

            since_dt = parse_datetime(since.strip())
            if since_dt is None:
                since_dt = parse_datetime(since.strip().replace(" ", "+"))
            if since_dt is None:
                return Response(
                    {"detail": "Invalid 'since' datetime format. Use ISO 8601."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        user = request.user

        if since_dt:
            categories_qs = Category.objects.filter(updated_at__gte=since_dt)
        else:
            categories_qs = Category.objects.filter(is_active=True)

        transactions_qs = Transaction.objects.filter(
            user=user, is_deleted=False,
        ).select_related("category")
        if since_dt:
            transactions_qs = transactions_qs.filter(updated_at__gte=since_dt)

        if since_dt:
            deleted_ids = list(
                Transaction.objects.filter(
                    user=user, is_deleted=True, deleted_at__gte=since_dt,
                ).values_list("id", flat=True)
            )
        else:
            deleted_ids = []

        user_settings, _ = UserSettings.objects.get_or_create(user=user)
        include_settings = since_dt is None or user_settings.updated_at >= since_dt

        server_timestamp = timezone.now()

        response_data = {
            "server_timestamp": server_timestamp,
            "categories": SyncCategorySerializer(categories_qs, many=True).data,
            "transactions": {
                "upserted": SyncTransactionSerializer(transactions_qs, many=True).data,
                "deleted_ids": deleted_ids,
            },
            "settings": SyncSettingsSerializer(user_settings).data if include_settings else None,
        }

        return Response(response_data)


class SyncPushView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=["Sync"],
        summary="Push local changes to server",
        description=(
            "Accepts created, updated, and deleted transactions plus settings. "
            "Created transactions return client_id → server_id mappings. "
            "Updates use server-wins conflict resolution based on `updated_at`. "
            "Deletes are soft (idempotent)."
        ),
        request=SyncPushRequestSerializer,
        responses={200: SyncPushResponseSerializer},
    )
    def post(self, request, *args, **kwargs):
        serializer = SyncPushRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        server_timestamp = timezone.now()
        user = request.user
        id_mappings = []
        conflicts = []

        tx_data = data.get("transactions", {})

        with db_transaction.atomic():
            for item in tx_data.get("created", []):
                category = Category.objects.filter(
                    code=item["category_code"].strip().lower(), is_active=True,
                ).first()
                if category is None:
                    continue

                client_id = item["client_id"]

                # Idempotency on retried pushes: return existing server id for same client_id.
                existing = Transaction.objects.filter(
                    user=user, client_id=client_id,
                ).only("id").first()
                if existing is not None:
                    id_mappings.append({
                        "client_id": client_id,
                        "server_id": existing.id,
                    })
                    continue

                original_amount = item["original_amount"]
                original_currency = item["original_currency"]

                try:
                    base_amount = calculate_base_amount(
                        original_amount=original_amount,
                        original_currency=original_currency,
                    )
                except BaseAmountOverflowError:
                    continue

                transaction = Transaction.objects.create(
                    user=user,
                    client_id=client_id,
                    category=category,
                    description=item.get("description", "").strip(),
                    original_amount=original_amount,
                    original_currency=original_currency,
                    base_amount=base_amount,
                    transaction_date=item["transaction_date"],
                )
                id_mappings.append({
                    "client_id": client_id,
                    "server_id": transaction.id,
                })

            for item in tx_data.get("updated", []):
                try:
                    transaction = Transaction.objects.select_for_update().get(
                        id=item["id"], user=user, is_deleted=False,
                    )
                except Transaction.DoesNotExist:
                    continue

                if transaction.updated_at > item["updated_at"]:
                    conflicts.append({
                        "id": transaction.id,
                        "server_version": SyncTransactionSerializer(transaction).data,
                    })
                    continue

                if "category_code" in item:
                    category = Category.objects.filter(
                        code=item["category_code"].strip().lower(), is_active=True,
                    ).first()
                    if category:
                        transaction.category = category

                if "description" in item:
                    transaction.description = item["description"].strip()

                original_amount = item.get("original_amount", transaction.original_amount)
                original_currency = item.get("original_currency", transaction.original_currency)

                if "original_amount" in item:
                    transaction.original_amount = original_amount
                if "original_currency" in item:
                    transaction.original_currency = original_currency
                if "transaction_date" in item:
                    transaction.transaction_date = item["transaction_date"]

                try:
                    transaction.base_amount = calculate_base_amount(
                        original_amount=original_amount,
                        original_currency=original_currency,
                    )
                except BaseAmountOverflowError:
                    continue
                transaction.save()

            for item in tx_data.get("deleted", []):
                try:
                    transaction = Transaction.objects.select_for_update().get(
                        id=item["id"], user=user, is_deleted=False,
                    )
                except Transaction.DoesNotExist:
                    continue

                transaction.is_deleted = True
                transaction.deleted_at = server_timestamp
                transaction.save()

            settings_data = data.get("settings")
            user_settings = None
            if settings_data:
                user_settings_obj, _ = UserSettings.objects.select_for_update().get_or_create(
                    user=user,
                )
                client_updated_at = settings_data.get("updated_at")
                if (
                    client_updated_at is None
                    or client_updated_at >= user_settings_obj.updated_at
                ):
                    changed = False
                    for field in (
                        "preferred_language",
                        "preferred_currency",
                    ):
                        if field in settings_data:
                            setattr(user_settings_obj, field, settings_data[field])
                            changed = True
                    if changed:
                        user_settings_obj.save()
                user_settings = user_settings_obj

        response_data = {
            "server_timestamp": server_timestamp,
            "id_mappings": id_mappings,
            "conflicts": conflicts,
            "settings": SyncSettingsSerializer(user_settings).data if user_settings else None,
        }

        return Response(response_data)
