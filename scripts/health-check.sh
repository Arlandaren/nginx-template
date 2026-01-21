#!/bin/bash

# Скрипт проверки доступности всех сайтов в конфигурации Nginx
# Проверяет HTTP ответ, SSL статус и время отклика

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🏥 Проверка здоровья сайтов..."
echo "------------------------------------------------------------"
printf "%-30s | %-10s | %-12s | %-8s\n" "DOMAIN" "STATUS" "RESPONSE" "TIME"
echo "------------------------------------------------------------"

# Проходим по всем конфигам сайтов
for conf in "$PROJECT_ROOT/nginx/sites/"*.conf; do
    [ -e "$conf" ] || continue
    
    # Игнорируем дефолтный конфиг
    filename=$(basename "$conf")
    if [[ "$filename" == "00-default.conf" ]]; then
        continue
    fi
    
    # Извлекаем основной домен из server_name
    DOMAIN=$(grep -m 1 "server_name" "$conf" | awk '{print $2}' | sed 's/;//')
    
    if [ -z "$DOMAIN" ] || [[ "$DOMAIN" == "_" ]]; then
        continue
    fi
    
    # Проверка через curl
    # -L (следовать редиректам), -I (только заголовки), -s (тихий режим)
    RESPONSE=$(curl -L -s -I -w "%{http_code} %{time_total}" "https://$DOMAIN" -o /dev/null --connect-timeout 5)
    
    HTTP_CODE=$(echo "$RESPONSE" | awk '{print $1}')
    TOTAL_TIME=$(echo "$RESPONSE" | awk '{print $2}')
    
    # Красим статус
    if [[ "$HTTP_CODE" == "200" ]]; then
        STATUS="✅ OK"
    elif [[ "$HTTP_CODE" == "301" ]] || [[ "$HTTP_CODE" == "302" ]]; then
        STATUS="🔄 REDIR"
    elif [[ "$HTTP_CODE" == "000" ]]; then
        STATUS="❌ FAIL"
        HTTP_CODE="Timeout"
    else
        STATUS="⚠️ WARN"
    fi
    
    # Проверка SSL (если не тайм-аут)
    SSL_INFO="-"
    if [[ "$HTTP_CODE" != "Timeout" ]]; then
        # Проверяем дату окончания сертификата через openssl
        EXPIRY_DATE=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
        if [ ! -z "$EXPIRY_DATE" ]; then
            DAYS=$(( ($(date -d "$EXPIRY_DATE" +%s) - $(date +%s)) / 86400 ))
            SSL_INFO="${DAYS}d left"
            if [ $DAYS -lt 14 ]; then
                SSL_INFO="⚠️ ${DAYS}d!"
            fi
        else
            SSL_INFO="No SSL"
        fi
    fi
    
    printf "%-30s | %-10s | %-12s | %-8s\n" "$DOMAIN" "$STATUS" "$HTTP_CODE" "${TOTAL_TIME}s"
    echo "   🔒 SSL: $SSL_INFO"
    echo "------------------------------------------------------------"
done

echo "📊 Проверка завершена."
