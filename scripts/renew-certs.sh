#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔄 Обновление SSL сертификатов..."

cd "$PROJECT_ROOT"
docker compose exec certbot certbot renew

# Релоад nginx после обновления сертификатов
docker compose exec nginx nginx -s reload

echo "✅ Сертификаты обновлены!"
