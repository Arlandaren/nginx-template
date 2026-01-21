#!/bin/bash

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$1" ]; then
    echo "Использование: ./remove-site.sh <domain>"
    echo "Пример: ./remove-site.sh myapp"
    exit 1
fi

DOMAIN=$1
FULL_DOMAIN="$DOMAIN"

echo "🗑️ Удаление сайта $DOMAIN"

# Удаляем конфиг
rm -f "$PROJECT_ROOT/nginx/sites/$DOMAIN.conf"

# Удаляем self-signed SSL сертификаты
rm -rf "$PROJECT_ROOT/nginx/ssl/sites/$FULL_DOMAIN"

# Удаляем Let's Encrypt сертификаты (если есть)
if [ -d "$PROJECT_ROOT/certbot/conf/live/$FULL_DOMAIN" ]; then
    echo "🔐 Удаление Let's Encrypt сертификата для $FULL_DOMAIN"
    docker run --rm \
        -v "$PROJECT_ROOT/certbot/conf:/etc/letsencrypt" \
        certbot/certbot delete --cert-name $FULL_DOMAIN --non-interactive
    rm -rf "$PROJECT_ROOT/certbot/conf/live/$FULL_DOMAIN"
    rm -rf "$PROJECT_ROOT/certbot/conf/archive/$FULL_DOMAIN"
    rm -rf "$PROJECT_ROOT/certbot/conf/renewal/${FULL_DOMAIN}.conf"
fi

# Релоад nginx
cd "$PROJECT_ROOT"
docker compose exec nginx nginx -s reload

echo "✅ Сайт $DOMAIN удален!"
echo "🗂️  Удалено:"
echo "   📝 Конфиг: $PROJECT_ROOT/nginx/sites/$DOMAIN.conf"
echo "   🔐 Self-signed SSL: $PROJECT_ROOT/nginx/ssl/sites/$FULL_DOMAIN"
echo "   🎫 Let's Encrypt: $PROJECT_ROOT/certbot/conf/live/$FULL_DOMAIN"