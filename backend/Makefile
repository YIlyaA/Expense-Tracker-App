LOCAL_COMPOSE = docker compose -f docker-compose.local.yml
PROD_COMPOSE = docker compose -f docker-compose.prod.yml

.PHONY: up down logs shell check test lint build prod-config

up:
	$(LOCAL_COMPOSE) up --build -d --remove-orphans

down:
	$(LOCAL_COMPOSE) down

down-v:
	$(LOCAL_COMPOSE) down -v

logs:
	$(LOCAL_COMPOSE) logs -f

shell:
	$(LOCAL_COMPOSE) exec web python manage.py shell

makemigrations:
	$(LOCAL_COMPOSE) run --rm web python manage.py makemigrations

migrate:
	$(LOCAL_COMPOSE) run --rm web python manage.py migrate

collectstatic:
	$(LOCAL_COMPOSE) run --rm web python manage.py collectstatic --noinput --clear

superuser:
	$(LOCAL_COMPOSE) run --rm web python manage.py createsuperuser

flush:
	$(LOCAL_COMPOSE) run --rm web python manage.py flush

mailpit:
	xdg-open http://localhost:8025

check:
	python manage.py check

test:
	pytest

lint:
	ruff check .

prod-config:
	$(PROD_COMPOSE) config
