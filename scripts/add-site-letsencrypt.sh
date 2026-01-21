#!/bin/bash

# Скрипт для автоматического добавления сайта и получения Let's Encrypt SSL
# Использует режим webroot для zero-downtime

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: $0 <domain> <port> [email]"
    echo "Пример: $0 mydomain.com 3000 admin@mydomain.com"
    exit 1
fi

DOMAIN=$1
PORT=$2
EMAIL=${3:-admin@$DOMAIN}
SAFE_FILENAME=$(echo "$DOMAIN" | sed 's/\./_/g')
CONF_FILE="$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

echo "🚀 Начинаем установку сайта $DOMAIN на порт $PORT..."

# 1. Создаем временную конфигурацию (только HTTP) для прохождения проверки Certbot
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

# 2. Получаем сертификат Let's Encrypt через webroot
echo "2️⃣  Запрос сертификата у Let's Encrypt (через webroot)..."
docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  -d "$DOMAIN"

# 3. Создаем финальную конфигурацию из шаблона
echo "3️⃣  Создание финальной конфигурации из шаблона..."
cp "$PROJECT_ROOT/nginx/templates/template.conf" "$CONF_FILE"
sed -i "s/{domain}/$DOMAIN/g" "$CONF_FILE"
sed -i "s/{port}/$PORT/g" "$CONF_FILE"

# 4. Проверяем конфиг и делаем релоад
echo "4️⃣  Применение финальной конфигурации..."
docker compose exec nginx nginx -t && docker compose exec nginx nginx -s reload

echo "--------------------------------------------------"
echo "✅ Все готово! Сайт $DOMAIN настроен."
echo "🌍 Адрес: https://$DOMAIN"
echo "📝 Файл конфига: $CONF_FILE"
echo "🔐 Сертификаты: $PROJECT_ROOT/certbot/conf/live/$DOMAIN/"
echo "--------------------------------------------------"
