#!/bin/bash

# Скрипт для автоматического обновления IP-адресов Cloudflare в конфиге Nginx
# Источники: https://www.cloudflare.com/ips-v4 и https://www.cloudflare.com/ips-v6

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REAL_IP_CONF="$PROJECT_ROOT/nginx/snippets/real-ip.conf"

echo "🌐 Обновление IP-адресов Cloudflare..."

# Скачиваем актуальные списки IP
IPS_V4=$(curl -s https://www.cloudflare.com/ips-v4)
IPS_V6=$(curl -s https://www.cloudflare.com/ips-v6)

if [ -z "$IPS_V4" ] || [ -z "$IPS_V6" ]; then
    echo "❌ Ошибка: Не удалось получить список IP от Cloudflare"
    exit 1
fi

# Подготавливаем содержимое файла
cat > "$REAL_IP_CONF" << EOF
# Cloudflare IP Ranges (AUTO-UPDATED)
# Last update: $(date)

# IPv4
EOF

for ip in $IPS_V4; do
    echo "set_real_ip_from $ip;" >> "$REAL_IP_CONF"
done

echo "" >> "$REAL_IP_CONF"
echo "# IPv6" >> "$REAL_IP_CONF"

for ip in $IPS_V6; do
    echo "set_real_ip_from $ip;" >> "$REAL_IP_CONF"
done

cat >> "$REAL_IP_CONF" << EOF

# Trust headers from these sources
real_ip_header CF-Connecting-IP;
# real_ip_recursive on;
EOF

echo "✅ Файл $REAL_IP_CONF успешно обновлен."

# Перезагружаем Nginx на сервере, если скрипт запущен локально внутри системы деплоя
# Или просто сообщаем, что нужен релоад
echo "🔄 Не забудьте задеплоить и перезагрузить Nginx: ./scripts/reload.sh"
