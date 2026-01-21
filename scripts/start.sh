#!/bin/bash

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Запуск Nginx stack..."

# Запускаем docker-compose
cd "$PROJECT_ROOT"
docker compose up -d

echo "✅ Nginx stack запущен!"
echo "📊 Проверить логи: docker compose logs nginx"
echo "🛑 Остановить: docker compose down"
