#!/bin/bash

# Скрипт для добавления CDN-сайта с кешированием и получением SSL
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: $0 <domain> <origin_url> [email]"
    echo "Пример: $0 cdn.example.com https://origin.example.com admin@example.com"
    exit 1
fi

DOMAIN=$1
ORIGIN=$2
EMAIL=${3:-admin@$DOMAIN}
SAFE_FILENAME=$(echo "$DOMAIN" | sed 's/\./_/g')
CONF_FILE="$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

echo "🚀 Начинаем установку CDN-сайта $DOMAIN (Origin: $ORIGIN)..."

# 1. Временный конфиг для Certbot
echo "1️⃣  Подготовка временной конфигурации Nginx..."
cat <<EOF > "$CONF_FILE"
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF

echo "Перезапуск Nginx для применения временного конфига..."
docker compose exec nginx nginx -s reload || docker compose restart nginx

# 2. Получаем SSL
echo "2️⃣  Запрос сертификата у Let's Encrypt..."
docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  -d "$DOMAIN"

# 3. Финальный конфиг из CDN-шаблона
echo "3️⃣  Создание финальной конфигурации из CDN-шаблона..."
cp "$PROJECT_ROOT/nginx/templates/cdn-template.conf" "$CONF_FILE"
sed -i "s/{domain}/$DOMAIN/g" "$CONF_FILE"
# Используем | как разделитель в sed, так как в URL есть слэши
sed -i "s|{origin}|$ORIGIN|g" "$CONF_FILE"

# 4. Релоад
echo "4️⃣  Применение финальной конфигурации..."
docker compose exec nginx nginx -t && docker compose exec nginx nginx -s reload

echo "--------------------------------------------------"
echo "✅ CDN готов! Сайт $DOMAIN теперь кеширует $ORIGIN."
echo "🌍 Адрес: https://$DOMAIN"
echo "📝 Файл конфига: $CONF_FILE"
echo "--------------------------------------------------"
