#!/bin/bash

# Главный управляющий скрипт для Nginx стека
# Использование: ./manage.sh <command> [args]

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

show_help() {
    echo "🎮 Nginx Stack Manager"
    echo "Использование: $0 [команда] [аргументы]"
    echo ""
    echo "Команды сайтов:"
    echo "  add <domain> <port> [email]   - Добавить сайт с Let's Encrypt"
    echo "  cdn <domain> <origin> [email]  - Добавить CDN (кеширующий) сайт"
    echo "  img <domain> <allowed_origin> - Добавить Image Proxy (ресайзер)"
    echo "  remove <domain>               - Удалить сайт и его сертификаты"
    echo "  health                        - Проверить статус всех сайтов"
    echo ""
    echo "Команды стека:"
    echo "  start/stop/restart            - Управление Docker-контейнерами"
    echo "  reload                        - Мягкая перезагрузка Nginx"
    echo "  status                        - Статус контейнеров и последние логи"
    echo "  logs [-f]                     - Просмотр логов"
    echo ""
    echo "Команды обслуживания:"
    echo "  check-certs                   - Проверить сроки SSL сертификатов"
    echo "  update-cf-ips                 - Обновить список IP Cloudflare"
    echo "  top                           - Анализ ТОП активных IP"
    echo "  rotate-logs                   - Ручная ротация логов"
    echo "  backup                        - Создать бэкап конфигов и SSL"
    echo ""
    echo "Деплой:"
    echo "  deploy <user@host> [key]      - Деплой на удаленный сервер"
}

case "$1" in
    add)
        "$SCRIPTS_DIR/add-site-letsencrypt.sh" "$2" "$3" "$4"
        ;;
    cdn)
        "$SCRIPTS_DIR/add-cdn-site.sh" "$2" "$3" "$4"
        ;;
    img)
        "$SCRIPTS_DIR/add-image-proxy.sh" "$2" "$3" "$4"
        ;;
    remove)
        "$SCRIPTS_DIR/remove-site.sh" "$2"
        ;;
    health)
        "$SCRIPTS_DIR/health-check.sh"
        ;;
    start|stop|restart|reload|status|logs)
        CMD=$1
        if [ "$CMD" == "logs" ] && [ "$2" == "-f" ]; then
            "$SCRIPTS_DIR/$CMD.sh" -f
        else
            "$SCRIPTS_DIR/$CMD.sh"
        fi
        ;;
    check-certs)
        "$SCRIPTS_DIR/check-certs.sh"
        ;;
    update-cf-ips)
        "$SCRIPTS_DIR/update-cloudflare-ips.sh"
        ;;
    top)
        "$SCRIPTS_DIR/top-ips.sh"
        ;;
    rotate-logs)
        "$SCRIPTS_DIR/rotate-logs.sh"
        ;;
    backup)
        "$SCRIPTS_DIR/backup.sh"
        ;;
    deploy)
        "$PROJECT_ROOT/deploy.sh" "$2" "$3" "$4"
        ;;
    *)
        show_help
        ;;
esac
