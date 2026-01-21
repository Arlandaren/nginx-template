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

# 1. Создаем временную конфигурацию для HTTP-01 вызова (если сайт новый)
# Или просто используем существующий конфиг если он есть.
# В нашем шаблоне уже есть обработка /.well-known/acme-challenge/
echo "1️⃣  Подготовка конфигурации Nginx..."
if [ ! -f "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf" ]; then
    cp "$PROJECT_ROOT/nginx/templates/template.conf" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
    sed -i "s/{domain}/$DOMAIN/g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
    sed -i "s/{port}/$PORT/g" "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
    
    # Временно комментируем SSL блок, так как сертов еще нет
    sed -i '18,44s/^/#/' "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
    
    echo "Перезапуск Nginx для применения временного конфига..."
    docker compose exec nginx nginx -s reload || docker compose restart nginx
fi

# 2. Получаем сертификат Let's Encrypt через webroot
echo "2️⃣  Запрос сертификата у Let's Encrypt (через webroot)..."
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  -d "$DOMAIN"

# 3. Активируем SSL в конфигурации
echo "3️⃣  Активация SSL конфигурации..."
# Раскомментируем HTTPS блок
sed -i '18,44s/^#//' "$PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"

# 4. Проверяем конфиг и делаем релоад
echo "4️⃣  Применение финальной конфигурации..."
docker compose exec nginx nginx -t && docker compose exec nginx nginx -s reload

echo "--------------------------------------------------"
echo "✅ Все готово! Сайт $DOMAIN настроен."
echo "🌍 Адрес: https://$DOMAIN"
echo "📝 Файл конфига: $PROJECT_ROOT/nginx/sites/$SAFE_FILENAME.conf"
echo "🔐 Сертификаты: $PROJECT_ROOT/certbot/conf/live/$DOMAIN/"
echo "--------------------------------------------------"
