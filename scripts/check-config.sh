#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔍 Проверка конфигурации Nginx..."

cd "$PROJECT_ROOT"
docker compose exec nginx nginx -t

echo ""
echo "📊 Активные сайты:"
ls "$PROJECT_ROOT/nginx/sites/"*.conf 2>/dev/null | xargs -n 1 basename || echo "Нет активных сайтов"

echo ""
echo "🌐 Проксирование:"
grep -h "server_name\|proxy_pass" "$PROJECT_ROOT/nginx/sites/"*.conf 2>/dev/null | grep -v "#" | grep -v "template" | sort || echo "Нет настроенных прокси"
