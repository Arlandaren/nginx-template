#!/bin/bash

echo "📊 Статус Nginx stack:"

cd /home/nginx
docker compose ps

echo ""
echo "🔍 Логи Nginx (последние 10 строк):"
docker compose logs nginx --tail=10
