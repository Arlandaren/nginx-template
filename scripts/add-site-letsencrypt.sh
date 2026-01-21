#!/bin/bash

# Скрипт для автоматического добавления сайта и получения Let's Encrypt SSL
# Этот скрипт объединяет функционал add-site.sh и migrate-to-letsencrypt.sh

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

echo "🚀 Начинаем установку сайта $DOMAIN на порт $PORT..."

# 1. Останавливаем Nginx, чтобы Certbot мог использовать 80 порт (standalone режим)
echo "1️⃣  Временная остановка Nginx для получения сертификатов..."
cd "$PROJECT_ROOT"
docker compose stop nginx

# 2. Получаем сертификат Let's Encrypt
echo "2️⃣  Запрос сертификата у Let's Encrypt (через standalone)..."
# Мы пробуем получить сертификат для основного домена. 
# Если нужен www, добавьте его через -d www.$DOMAIN
docker run --rm \
  -v "$PROJECT_ROOT/certbot/conf:/etc/letsencrypt" \
  -v "$PROJECT_ROOT/certbot/www:/var/www/certbot" \
  -p 80:80 \
  -p 443:443 \
  certbot/certbot certonly \
  --standalone \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  -d "$DOMAIN"

# 3. Создаем конфигурационный файл из шаблона
echo "3️⃣  Создание конфигурации Nginx..."
cp "$PROJECT_ROOT/nginx/templates/template.conf" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

# Заменяем {domain} и {port}
sed -i "s/{domain}/$DOMAIN/g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
sed -i "s/{port}/$PORT/g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

# Исправляем пути к SSL (меняем стандартные на Let's Encrypt)
sed -i "s|/etc/nginx/ssl/sites/$DOMAIN/fullchain.pem|/etc/letsencrypt/live/$DOMAIN/fullchain.pem|g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
sed -i "s|/etc/nginx/ssl/sites/$DOMAIN/privkey.pem|/etc/letsencrypt/live/$DOMAIN/privkey.pem|g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

# 4. Запускаем Nginx обратно
echo "4️⃣  Запуск Nginx с новой конфигурацией..."
docker compose start nginx

# 5. Проверяем конфиг и делаем релоад на всякий случай
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload

echo "--------------------------------------------------"
echo "✅ Все готово! Сайт $DOMAIN настроен."
echo "🌍 Адрес: https://$DOMAIN"
echo "📝 Файл конфига: $PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
echo "🔐 Сертификаты: $PROJECT_ROOT/certbot/conf/live/$DOMAIN/"
echo "--------------------------------------------------"
