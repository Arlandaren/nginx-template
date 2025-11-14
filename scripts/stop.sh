#!/bin/bash

echo "🛑 Остановка Nginx stack..."

cd /home/nginx
docker compose down

echo "✅ Nginx stack остановлен!"
