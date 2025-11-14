#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: ./migrate-to-letsencrypt-fixed2.sh <domain-file> <email>"
    echo "Пример: ./migrate-to-letsencrypt-fixed2.sh easyfund_aldar_space algenzalo@gmail.com"
    exit 1
fi

DOMAIN_FILE=$1
EMAIL=$2
FULL_DOMAIN=$(echo "$DOMAIN_FILE" | sed 's/_/./g')

echo "🚀 Миграция $FULL_DOMAIN с self-signed на Let's Encrypt..."

# Проверяем существование конфига
if [ ! -f "/home/nginx/nginx/sites/$DOMAIN_FILE.conf" ]; then
    echo "❌ Конфиг /home/nginx/nginx/sites/$DOMAIN_FILE.conf не найден"
    ls /home/nginx/nginx/sites/*.conf | xargs -n 1 basename
    exit 1
fi

echo "1. Останавливаем nginx..."
cd /home/nginx
docker compose stop nginx

echo "2. Получаем Let's Encrypt сертификат..."
# Используем прямой вызов certbot без entrypoint
docker run --rm \
  -v /home/nginx/certbot/conf:/etc/letsencrypt \
  -v /home/nginx/certbot/www:/var/www/certbot \
  -p 80:80 \
  -p 443:443 \
  certbot/certbot certonly \
  --standalone \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  -d $FULL_DOMAIN

echo "3. Запускаем nginx обратно..."
docker compose start nginx

echo "4. Обновляем конфиг для использования Let's Encrypt..."
sed -i \
  -e "s|ssl_certificate /etc/nginx/ssl/sites/$FULL_DOMAIN/fullchain.pem;|ssl_certificate /etc/letsencrypt/live/$FULL_DOMAIN/fullchain.pem;|" \
  -e "s|ssl_certificate_key /etc/nginx/ssl/sites/$FULL_DOMAIN/privkey.pem;|ssl_certificate_key /etc/letsencrypt/live/$FULL_DOMAIN/privkey.pem;|" \
  /home/nginx/nginx/sites/$DOMAIN_FILE.conf

echo "5. Перезагружаем nginx..."
docker compose exec nginx nginx -s reload

echo "✅ Миграция $FULL_DOMAIN завершена!"
echo "📁 Сертификаты: /home/nginx/certbot/conf/live/$FULL_DOMAIN/"
