FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential curl libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements /tmp/requirements
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements/local.txt

COPY . /app

EXPOSE 8000
