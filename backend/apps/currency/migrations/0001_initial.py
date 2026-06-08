from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies: list = []

    operations = [
        migrations.CreateModel(
            name="ExchangeRate",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "currency",
                    models.CharField(
                        choices=[("PLN", "PLN"), ("USD", "USD"), ("EUR", "EUR")],
                        max_length=3,
                        unique=True,
                    ),
                ),
                ("rate_to_base", models.DecimalField(decimal_places=6, max_digits=14)),
                ("source", models.CharField(max_length=64)),
                ("fetched_at", models.DateTimeField(auto_now=True)),
                ("effective_date", models.DateField()),
            ],
            options={
                "verbose_name": "exchange rate",
                "verbose_name_plural": "exchange rates",
                "ordering": ("currency",),
            },
        ),
    ]
