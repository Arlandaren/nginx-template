#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📊 Статус Nginx stack..."

cd "$PROJECT_ROOT"
docker compose ps

echo ""
echo "🔍 Логи Nginx (последние 10 строк):"
docker compose logs nginx --tail=10
