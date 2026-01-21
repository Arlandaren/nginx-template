#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🛑 Остановка Nginx stack..."

cd "$PROJECT_ROOT"
docker compose down

echo "✅ Nginx stack остановлен!"
