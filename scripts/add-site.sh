#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: ./add-site.sh <domain> <port>"
    echo "Пример: ./add-site.sh myapp 3000"
    exit 1
fi

DOMAIN=$1
PORT=$2

echo "🌐 Добавление сайта $DOMAIN на порт $PORT"

# Создаем безопасное имя файла (заменяем точки на подчеркивания)
SAFE_FILENAME=$(echo "$DOMAIN" | sed 's/\./_/g')

# Создаем конфиг из шаблона
cp /home/nginx/nginx/templates/template.conf /home/nginx/nginx/sites/$SAFE_FILENAME.conf

# Заменяем {domain} в конфиге (экранируем точки для sed)
ESCAPED_DOMAIN=$(echo "$DOMAIN" | sed 's/\./\\./g')
sed -i "s/{domain}/$ESCAPED_DOMAIN/g" /home/nginx/nginx/sites/$SAFE_FILENAME.conf
sed -i "s/{port}/$PORT/g" /home/nginx/nginx/sites/$SAFE_FILENAME.conf

# Создаем директорию для SSL
mkdir -p /home/nginx/nginx/ssl/sites/$DOMAIN

# Генерируем тестовый SSL сертификат
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /home/nginx/nginx/ssl/sites/$DOMAIN/privkey.pem \
    -out /home/nginx/nginx/ssl/sites/$DOMAIN/fullchain.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=$DOMAIN" 2>/dev/null

# Релоад nginx
cd /home/nginx
docker compose exec nginx nginx -s reload

echo "✅ Сайт $DOMAIN добавлен!"
echo "📝 Конфиг: /home/nginx/nginx/sites/$SAFE_FILENAME.conf"
echo "🔐 SSL: /home/nginx/nginx/ssl/sites/$DOMAIN/"
echo "🌍 Проксирует на: http://127.0.0.1:$PORT"
