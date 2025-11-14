#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Использование: ./remove-site.sh <domain>"
    echo "Пример: ./remove-site.sh myapp"
    exit 1
fi

DOMAIN=$1

echo "🗑️ Удаление сайта $DOMAIN"

# Удаляем конфиг
rm -f /home/nginx/nginx/sites/$DOMAIN.conf

# Удаляем SSL сертификаты
rm -rf /home/nginx/nginx/ssl/sites/$DOMAIN.com

# Релоад nginx
cd /home/nginx
docker compose exec nginx nginx -s reload

echo "✅ Сайт $DOMAIN удален!"
