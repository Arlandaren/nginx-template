#!/bin/bash

# Скрипт для деплоя конфигурации Nginx на удаленный сервер
# Использование: ./deploy.sh <user@host> [key_or_pass_file] [target_dir]

set -e

REMOTE_TARGET=$1
SECRET_FILE=$2
TARGET_DIR=${3:-"/home/nginx"}

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$REMOTE_TARGET" ]; then
    echo "❌ Ошибка: Не указан target (user@host)"
    echo "Использование: $0 <user@host> [key_or_pass_file] [target_dir]"
    echo "Пример: $0 root@86.110.194.4 ./id_rsa /home/nginx"
    exit 1
fi

SSH_OPTS="-o StrictHostKeyChecking=no"

# Определяем стратегию аутентификации
if [ -n "$SECRET_FILE" ] && [ -f "$SECRET_FILE" ]; then
    # Проверяем, является ли файл SSH ключом
    if grep -q "PRIVATE KEY" "$SECRET_FILE"; then
        echo "🔑 Используется SSH ключ: $SECRET_FILE"
        SSH_CMD="ssh -i $SECRET_FILE $SSH_OPTS"
        RSYNC_OPTS="-avz --delete -e \"ssh -i $SECRET_FILE $SSH_OPTS\""
    else
        echo "⌨️ Используется sshpass с файлом пароля: $SECRET_FILE"
        if ! command -v sshpass &> /dev/null; then
            echo "❌ Ошибка: sshpass не установлен."
            exit 1
        fi
        SSH_CMD="sshpass -f $SECRET_FILE ssh $SSH_OPTS"
        RSYNC_OPTS="-avz --delete -e \"sshpass -f $SECRET_FILE ssh $SSH_OPTS\""
    fi
else
    echo "ℹ️  Секретный файл не указан. Используется стандартный SSH."
    SSH_CMD="ssh $SSH_OPTS"
    RSYNC_OPTS="-avz --delete"
fi

# Список исключений для rsync
EXCLUDE_ARGS="--exclude='.git*' --exclude='logs/*' --exclude='*.swp' --exclude='.env' --exclude='node_modules'"

echo "🚀 Подготовка к деплою на $REMOTE_TARGET:$TARGET_DIR..."

# Создаем директорию на сервере
$SSH_CMD "$REMOTE_TARGET" "mkdir -p $TARGET_DIR"

echo "📦 Копирование файлов..."
eval "rsync $RSYNC_OPTS $EXCLUDE_ARGS $PROJECT_ROOT/ $REMOTE_TARGET:$TARGET_DIR/"

echo "✅ Файлы синхронизированы."
echo "🔄 Перезапуск сервисов на удаленном сервере..."

# Перезапуск
$SSH_CMD "$REMOTE_TARGET" "cd $TARGET_DIR && (docker compose restart nginx || docker-compose restart nginx)"

echo "🎉 Деплой успешно завершен!"
