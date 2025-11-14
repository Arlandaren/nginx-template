#!/bin/bash

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Использование: ./add-site-le.sh <domain> <port> [email]"
    echo "Пример: ./add-site-le.sh myapp 3000 my@email.com"
    exit 1
fi

DOMAIN=$1
PORT=$2
EMAIL=${3:-admin@$DOMAIN.com}
FULL_DOMAIN="$DOMAIN.com"

echo "Добавление сайта $FULL_DOMAIN на порт $PORT с Let's Encrypt..."

# Создаем конфиг из шаблона
cp /home/nginx/nginx/sites/template.conf /home/nginx/nginx/sites/$DOMAIN.conf
sed -i "s/{domain}/$DOMAIN/g" /home/nginx/nginx/sites/$DOMAIN.conf
sed -i "s/{port}/$PORT/g" /home/nginx/nginx/sites/$DOMAIN.conf

# Получаем Let's Encrypt сертификат
./scripts/setup-letsencrypt.sh $FULL_DOMAIN $EMAIL

echo "Сайт $FULL_DOMAIN добавлен с Let's Encrypt SSL!"
echo "Конфиг: /home/nginx/nginx/sites/$DOMAIN.conf"
echo "SSL: /home/nginx/certbot/conf/live/$FULL_DOMAIN/"
echo "Проксирует на: http://127.0.0.1:$PORT"
