#!/bin/bash

echo "Принудительное обновление SSL сертификатов..."

cd /home/nginx

# Останавливаем временно nginx для обновления
docker compose stop nginx

# Обновляем сертификаты
docker compose run --rm certbot renew --force-renewal

# Запускаем nginx обратно
docker compose start nginx

echo "Сертификаты принудительно обновлены!"
echo "Новые сроки действия:"
./scripts/check-certs.sh
