#!/bin/bash

set -e

echo "🚀 Запуск Nginx stack..."

# Проверяем существование DH parameters
if [ ! -f /home/nginx/nginx/ssl/dhparam.pem ]; then
    echo "⚠️  DH parameters не найдены. Запустите сначала: ./scripts/init-ssl.sh"
    exit 1
fi

# Запускаем docker-compose
cd /home/nginx
docker compose up -d

echo "✅ Nginx stack запущен!"
echo "📊 Проверить логи: docker compose logs nginx"
echo "🛑 Остановить: docker compose down"
