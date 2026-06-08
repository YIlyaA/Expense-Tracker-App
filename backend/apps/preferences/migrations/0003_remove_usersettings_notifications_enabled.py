from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ("preferences", "0002_usersettings_updated_at"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="usersettings",
            name="notifications_enabled",
        ),
    ]
