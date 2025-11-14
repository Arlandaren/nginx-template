#!/bin/bash

echo "🔍 Проверка конфигурации Nginx..."

cd /home/nginx
docker compose exec nginx nginx -t

echo ""
echo "📊 Активные сайты:"
ls /home/nginx/nginx/sites/*.conf 2>/dev/null | xargs -n 1 basename || echo "Нет активных сайтов"

echo ""
echo "🌐 Проксирование:"
grep -h "server_name\|proxy_pass" /home/nginx/nginx/sites/*.conf 2>/dev/null | grep -v "#" | grep -v "template" | sort || echo "Нет настроенных прокси"
