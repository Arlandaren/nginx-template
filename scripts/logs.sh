#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$PROJECT_ROOT"

if [ "$1" = "-f" ]; then
    docker compose logs nginx -f
else
    docker compose logs nginx
fi
