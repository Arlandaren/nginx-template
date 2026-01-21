#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔍 Проверка статуса SSL сертификатов..."

cd "$PROJECT_ROOT"

echo "📋 Список сертификатов в certbot:"
# Используем прямое обращение к certbot без docker compose run
docker run --rm \
  -v "$PROJECT_ROOT/certbot/conf:/etc/letsencrypt" \
  certbot/certbot certificates

echo ""
echo "📊 Информация о сроках действия:"

# Проверяем каждый домен в конфигах
for conf_file in nginx/sites/*.conf; do
    if [ -f "$conf_file" ]; then
        # Ищем домены с Let's Encrypt
        DOMAIN=$(grep -o "ssl_certificate /etc/letsencrypt/live/[^/]*" "$conf_file" | cut -d'/' -f6 | head -1)
        if [ ! -z "$DOMAIN" ]; then
            CERT_FILE="$PROJECT_ROOT/certbot/conf/live/$DOMAIN/fullchain.pem"
            if [ -f "$CERT_FILE" ]; then
                EXPIRY_DATE=$(openssl x509 -in "$CERT_FILE" -noout -enddate | cut -d= -f2)
                DAYS_LEFT=$(( ($(date -d "$EXPIRY_DATE" +%s) - $(date +%s)) / 86400 ))
                echo "  ✅ $DOMAIN: истекает через $DAYS_LEFT дней ($EXPIRY_DATE)"
            else
                echo "  ❌ $DOMAIN: Let's Encrypt сертификат не найден"
            fi
        fi
        
    fi
done

echo ""
echo "📁 Проверка структуры certbot:"
if [ -d "$PROJECT_ROOT/certbot/conf/live" ]; then
    echo "  📂 Домены в certbot:"
    ls -la "$PROJECT_ROOT/certbot/conf/live/" 2>/dev/null | grep "^d" | awk '{print "    🏷️  " $9}'
else
    echo "  ❌ Папка certbot/conf/live не существует"
fi

echo ""
echo "🔄 Статус автообновления:"
docker compose ps certbot | grep certbot
