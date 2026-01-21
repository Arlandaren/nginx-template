#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Принудительное обновление SSL сертификатов..."

cd "$PROJECT_ROOT"

# Останавливаем временно nginx для обновления
docker compose stop nginx

# Обновляем сертификаты
docker compose run --rm certbot renew --force-renewal

# Запускаем nginx обратно
docker compose start nginx

echo "Сертификаты принудительно обновлены!"
echo "Новые сроки действия:"
./scripts/check-certs.sh
