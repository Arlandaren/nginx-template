#!/bin/bash

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$1" ]; then
    echo "Использование: ./setup-letsencrypt.sh <domain> [email]"
    echo "Пример: ./setup-letsencrypt.sh mydomain.com my@email.com"
    exit 1
fi

DOMAIN=$1
EMAIL=${2:-admin@$DOMAIN}

echo "Настройка Let's Encrypt для $DOMAIN..."

# Проверяем, что домен резолвится на localhost (для тестирования)
if ! grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
    echo "Предупреждение: $DOMAIN не найден в /etc/hosts"
    echo "   Для продакшена убедитесь, что DNS запись указывает на этот сервер"
fi

# Создаем временный конфиг для получения сертификата
TEMP_CONF="/tmp/nginx-temp-$$.conf"

cat > $TEMP_CONF << TEMPLATE
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 444;  # Закрываем соединение для других запросов
    }
}
TEMPLATE

# Копируем временный конфиг
cp $TEMP_CONF "$PROJECT_ROOT/nginx/sites/temp-$DOMAIN.conf"

# Перезагружаем nginx для применения временного конфига
cd "$PROJECT_ROOT"
docker compose exec nginx nginx -s reload

echo "Получение SSL сертификата от Let's Encrypt..."

# Получаем сертификат
docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path /var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d $DOMAIN \
    -d www.$DOMAIN

# Удаляем временный конфиг
rm -f "$PROJECT_ROOT/nginx/sites/temp-$DOMAIN.conf"

# Перезагружаем nginx снова
docker compose exec nginx nginx -s reload

echo "Let's Encrypt успешно настроен для $DOMAIN!"
echo "Сертификаты расположены в: $PROJECT_ROOT/certbot/conf/live/$DOMAIN/"
echo "Автообновление настроено (проверка каждые 12 часов)"

# Показываем информацию о сертификате
echo ""
echo "Информация о сертификате:"
docker compose run --rm certbot certificates --domain $DOMAIN
