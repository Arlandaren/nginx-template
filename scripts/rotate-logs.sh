#!/bin/bash

# Скрипт ротации логов Nginx на хосте
# Рекомендуется добавить в crontab: 0 0 * * * /path/to/rotate-logs.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs/nginx"
KEEP_DAYS=14

echo "🔄 Ротация логов в $LOG_DIR..."

# 1. Архивируем текущие логи
if [ -f "$LOG_DIR/access.log" ]; then
    DATE=$(date +%Y-%m-%d_%H-%M-%S)
    mv "$LOG_DIR/access.log" "$LOG_DIR/access.log.$DATE"
    gzip "$LOG_DIR/access.log.$DATE"
fi

if [ -f "$LOG_DIR/error.log" ]; then
    DATE=$(date +%Y-%m-%d_%H-%M-%S)
    mv "$LOG_DIR/error.log" "$LOG_DIR/error.log.$DATE"
    gzip "$LOG_DIR/error.log.$DATE"
fi

# 2. Сигнализируем Nginx переоткрыть файлы логов (без рестарта)
cd "$PROJECT_ROOT"
docker compose exec -T nginx nginx -s reopen 2>/dev/null || echo "⚠️  Не удалось переоткрыть логи (Nginx не запущен?)"

# 3. Удаляем логи старее чем KEEP_DAYS
find "$LOG_DIR" -name "*.gz" -type f -mtime +$KEEP_DAYS -delete

echo "✅ Ротация логов завершена. Старые логи (>$KEEP_DAYS дней) удалены."
