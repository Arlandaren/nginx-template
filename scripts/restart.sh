#!/bin/bash

echo "🔄 Перезапуск Nginx stack..."

cd /home/nginx
docker compose restart

echo "✅ Nginx stack перезапущен!"
