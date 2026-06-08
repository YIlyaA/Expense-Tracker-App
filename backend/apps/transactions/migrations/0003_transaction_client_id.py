from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("transactions", "0002_transaction_deleted_at_transaction_is_deleted_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="transaction",
            name="client_id",
            field=models.UUIDField(blank=True, null=True),
        ),
        migrations.AddConstraint(
            model_name="transaction",
            constraint=models.UniqueConstraint(
                condition=models.Q(("client_id__isnull", False)),
                fields=("user", "client_id"),
                name="uniq_transaction_user_client_id",
            ),
        ),
    ]
