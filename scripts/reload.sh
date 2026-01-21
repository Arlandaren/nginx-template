#!/bin/bash

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔄 Reload Nginx configuration..."

cd "$PROJECT_ROOT"
docker compose exec nginx nginx -s reload

echo "✅ Nginx configuration reloaded!"
