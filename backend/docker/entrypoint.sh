#!/bin/sh
set -eu

python - <<'PY'
import os
import socket
import sys
import time
from urllib.parse import urlparse


def wait_for_service(url, default_host="", default_port=0, attempts=30):
    parsed = urlparse(url)
    host = parsed.hostname or default_host
    port = parsed.port or default_port
    if not host or not port:
        return

    for _ in range(attempts):
        try:
            with socket.create_connection((host, port), timeout=2):
                return
        except OSError:
            time.sleep(1)

    sys.stderr.write(f"Service {host}:{port} did not become available in time.\n")
    sys.exit(1)


database_url = os.environ.get("DATABASE_URL", "")
if database_url.startswith("postgres"):
    wait_for_service(database_url, default_port=5432)

redis_url = os.environ.get("REDIS_URL", "")
if redis_url:
    wait_for_service(redis_url, default_port=6379)
PY

exec "$@"
