#!/bin/bash

set -e

# Определяем корень проекта
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔐 Инициализация SSL..."

# Генерация DH parameters
echo "Генерация DH parameters (это займет некоторое время)..."
openssl dhparam -out "$PROJECT_ROOT/nginx/ssl/dhparam.pem" 2048

# Создаем self-signed сертификаты для примеров
echo "Создание тестовых сертификатов..."

domains=("frontend" "api")

for domain in "${domains[@]}"; do
    echo "Создание сертификата для $domain.com..."
    mkdir -p "$PROJECT_ROOT/nginx/ssl/sites/$domain.com"
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$PROJECT_ROOT/nginx/ssl/sites/$domain.com/privkey.pem" \
        -out "$PROJECT_ROOT/nginx/ssl/sites/$domain.com/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=$domain.com"
done

echo "✅ SSL инициализирован!"
echo "⚠️  Для продакшена замените тестовые сертификаты на реальные (Let's Encrypt)"
