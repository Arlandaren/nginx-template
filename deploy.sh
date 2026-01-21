#!/bin/bash

# Скрипт для деплоя конфигурации Nginx на удаленный сервер
# Использование: ./deploy.sh <user@host> [password_file] [target_dir]

set -e

REMOTE_TARGET=$1
PWD_FILE=$2
TARGET_DIR=${3:-"/home/nginx"}

# Определяем корень проекта (директория, где лежит этот скрипт)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$REMOTE_TARGET" ]; then
    echo "❌ Ошибка: Не указан target (user@host)"
    echo "Использование: $0 <user@host> [password_file] [target_dir]"
    echo "Пример: $0 root@1.2.3.4 .ssh_pass /opt/nginx"
    exit 1
fi

# Проверка наличия sshpass если указан файл пароля
if [ -n "$PWD_FILE" ] && [ -f "$PWD_FILE" ]; then
    if ! command -v sshpass &> /dev/null; then
        echo "❌ Ошибка: sshpass не установлен. Установите его: sudo apt install sshpass"
        exit 1
    fi
    SSH_CMD="sshpass -f $PWD_FILE ssh -o StrictHostKeyChecking=no"
    RSYNC_CMD="sshpass -f $PWD_FILE rsync -avz --delete -e 'ssh -o StrictHostKeyChecking=no'"
else
    echo "ℹ️  Файл пароля не указан или не найден. Используется обычный SSH (проверьте ключи)."
    SSH_CMD="ssh -o StrictHostKeyChecking=no"
    RSYNC_CMD="rsync -avz --delete"
fi

# Список исключений для rsync
EXCLUDE_ARGS="--exclude='.git*' --exclude='logs/*' --exclude='*.swp' --exclude='.env' --exclude='node_modules'"

echo "🚀 Подготовка к деплою на $REMOTE_TARGET:$TARGET_DIR..."

# Создаем директорию на сервере
$SSH_CMD "$REMOTE_TARGET" "mkdir -p $TARGET_DIR"

echo "📦 Копирование файлов..."
eval "$RSYNC_CMD $EXCLUDE_ARGS $PROJECT_ROOT/ $REMOTE_TARGET:$TARGET_DIR/"

echo "✅ Файлы синхронизированы."
echo "🔄 Перезапуск сервисов на удаленном сервере..."

# Проверяем наличие docker compose на сервере и перезапускаем
$SSH_CMD "$REMOTE_TARGET" "cd $TARGET_DIR && (docker compose restart nginx || docker-compose restart nginx)"

echo "🎉 Деплой успешно завершен!"
