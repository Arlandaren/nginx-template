#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔄 Перезапуск Nginx stack..."

cd "$PROJECT_ROOT"
docker compose restart

echo "✅ Nginx stack перезапущен!"
