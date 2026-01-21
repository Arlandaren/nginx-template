#!/bin/bash

# Скрипт бэкапа конфигурации Nginx и сертификатов
# По умолчанию сохраняет в папку backups/

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="nginx_backup_$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "📦 Создание бэкапа конфигурации и SSL..."

tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    -C "$PROJECT_ROOT" \
    nginx/sites \
    nginx/nginx.conf \
    nginx/snippets \
    certbot/conf

echo "✅ Бэкап создан: $BACKUP_DIR/$BACKUP_NAME"

# Удаляем бэкапы старше 30 дней
find "$BACKUP_DIR" -name "nginx_backup_*.tar.gz" -type f -mtime +30 -delete
echo "🧹 Старые бэкапы (>30 дней) удалены."
