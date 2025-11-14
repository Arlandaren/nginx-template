#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Использование: ./remove-site.sh <domain>"
    echo "Пример: ./remove-site.sh myapp"
    exit 1
fi

DOMAIN=$1
FULL_DOMAIN="$DOMAIN"

echo "🗑️ Удаление сайта $DOMAIN"

# Удаляем конфиг
rm -f /home/nginx/nginx/sites/$DOMAIN.conf

# Удаляем self-signed SSL сертификаты
rm -rf /home/nginx/nginx/ssl/sites/$FULL_DOMAIN

# Удаляем Let's Encrypt сертификаты (если есть)
if [ -d "/home/nginx/certbot/conf/live/$FULL_DOMAIN" ]; then
    echo "🔐 Удаление Let's Encrypt сертификата для $FULL_DOMAIN"
    docker run --rm \
        -v /home/nginx/certbot/conf:/etc/letsencrypt \
        certbot/certbot delete --cert-name $FULL_DOMAIN --non-interactive
    rm -rf /home/nginx/certbot/conf/live/$FULL_DOMAIN
    rm -rf /home/nginx/certbot/conf/archive/$FULL_DOMAIN
    rm -rf /home/nginx/certbot/conf/renewal/${FULL_DOMAIN}.conf
fi

# Релоад nginx
cd /home/nginx
docker compose exec nginx nginx -s reload

echo "✅ Сайт $DOMAIN удален!"
echo "🗂️  Удалено:"
echo "   📝 Конфиг: /home/nginx/nginx/sites/$DOMAIN.conf"
echo "   🔐 Self-signed SSL: /home/nginx/nginx/ssl/sites/$FULL_DOMAIN"
echo "   🎫 Let's Encrypt: /home/nginx/certbot/conf/live/$FULL_DOMAIN"