#!/bin/bash

echo "🔍 Простая проверка SSL сертификатов..."

cd /home/nginx

echo "📁 Домены с Let's Encrypt:"
if [ -d "certbot/conf/live" ]; then
    for domain_dir in certbot/conf/live/*; do
        if [ -d "$domain_dir" ]; then
            domain=$(basename "$domain_dir")
            if [ -f "$domain_dir/fullchain.pem" ]; then
                EXPIRY_DATE=$(openssl x509 -in "$domain_dir/fullchain.pem" -noout -enddate 2>/dev/null | cut -d= -f2)
                if [ $? -eq 0 ]; then
                    DAYS_LEFT=$(( ($(date -d "$EXPIRY_DATE" +%s) - $(date +%s)) / 86400 ))
                    echo "  ✅ $domain: Let's Encrypt (осталось $DAYS_LEFT дней)"
                else
                    echo "  ⚠️  $domain: Let's Encrypt (битый сертификат)"
                fi
            else
                echo "  ❌ $domain: нет fullchain.pem"
            fi
        fi
    done
else
    echo "  ❌ Нет Let's Encrypt сертификатов"
fi

echo ""
echo "📁 Домены с self-signed:"
if [ -d "nginx/ssl/sites" ]; then
    for domain_dir in nginx/ssl/sites/*; do
        if [ -d "$domain_dir" ]; then
            domain=$(basename "$domain_dir")
            if [ -f "$domain_dir/fullchain.pem" ]; then
                echo "  🔄 $domain: self-signed"
            fi
        fi
    done
fi

echo ""
echo "🌐 Активные домены в nginx:"
grep -h "server_name" nginx/sites/*.conf 2>/dev/null | grep -v "server_name _;" | grep -v "#" | sort | uniq | sed 's/^[ \t]*//' | sed 's/;/ /' | while read line; do
    echo "  🏷️  $line"
done
