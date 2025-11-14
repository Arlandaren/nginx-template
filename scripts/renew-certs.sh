#!/bin/bash

echo "🔄 Обновление SSL сертификатов..."

cd /home/nginx
docker compose exec certbot certbot renew

# Релоад nginx после обновления сертификатов
docker compose exec nginx nginx -s reload

echo "✅ Сертификаты обновлены!"
