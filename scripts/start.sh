#!/bin/bash

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Запуск Nginx stack..."

# Проверяем существование DH parameters
if [ ! -f "$PROJECT_ROOT/nginx/ssl/dhparam.pem" ]; then
    echo "⚠️  DH parameters не найдены. Запустите сначала: ./scripts/init-ssl.sh"
    exit 1
fi

# Запускаем docker-compose
cd "$PROJECT_ROOT"
docker compose up -d

echo "✅ Nginx stack запущен!"
echo "📊 Проверить логи: docker compose logs nginx"
echo "🛑 Остановить: docker compose down"
