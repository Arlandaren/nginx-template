#!/bin/bash

# Скрипт для удаления сайта и его сертификатов
# Использование: ./remove-site.sh <domain>

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$1" ]; then
    echo "Использование: $0 <domain>"
    echo "Пример: $0 mydomain.com"
    exit 1
fi

DOMAIN=$1
SAFE_FILENAME=$(echo "$DOMAIN" | sed 's/\./_/g')

echo "🗑️ Удаление сайта $DOMAIN..."

# 1. Удаляем конфиг (пробуем оба варианта имени файла)
if [ -f "$PROJECT_ROOT/nginx/sites/$DOMAIN.conf" ]; then
    rm -f "$PROJECT_ROOT/nginx/sites/$DOMAIN.conf"
elif [ -f "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf" ]; then
    rm -f "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
fi

# 2. Удаляем Let's Encrypt сертификаты (через официальный механизм)
if [ -d "$PROJECT_ROOT/certbot/conf/live/$DOMAIN" ]; then
    echo "🔐 Удаление сертификатов Let's Encrypt для $DOMAIN..."
    docker run --rm \
        -v "$PROJECT_ROOT/certbot/conf:/etc/letsencrypt" \
        certbot/certbot delete --cert-name "$DOMAIN" --non-interactive
fi

# 3. Релоад Nginx
echo "🔄 Обновление конфигурации Nginx..."
cd "$PROJECT_ROOT"
docker compose exec nginx nginx -s reload

echo "✅ Сайт $DOMAIN полностью удален!"