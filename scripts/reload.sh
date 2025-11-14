#!/bin/bash

echo "🔄 Reload Nginx configuration..."

cd /home/nginx
docker compose exec nginx nginx -s reload

echo "✅ Nginx configuration reloaded!"
