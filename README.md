# 🚀 Nginx Proxy Manager в Docker

rsync -avz --delete \
            --exclude='.git/' \
            --exclude='node_modules/' \
            -e "ssh -i /path/ -o StrictHostKeyChecking=no" \
            ./ \
            root@addr:/home/nginx/


rsync -avz --delete \
            --exclude='.git/' \
            --exclude='node_modules/' \
            --exclude='nginx/sites-enabled/*.conf' \
            --exclude='nginx/conf.d/*.conf' \
            -e "ssh -i /path/ -o StrictHostKeyChecking=no" \
            ./ \
            root@addr:/home/nginx/

# Список папок и файлов для обновления
rsync -avz -e "ssh -i /path/" ./nginx/nginx.conf root@addr:/home/nginx/nginx/
rsync -avz -e "ssh -i /path/" ./nginx/snippets/ root@addr:/home/nginx/nginx/snippets/
rsync -avz -e "ssh -i /path/" ./nginx/templates/ root@addr:/home/nginx/nginx/templates/
rsync -avz -e "ssh -i /path/" ./scripts/ root@addr:/home/nginx/scripts/

Полная система для проксирования Docker приложений через Nginx с SSL.

## 📁 Структура
/home/nginx/
├── docker-compose.yml
├── nginx/
│ ├── nginx.conf # Основной конфиг
│ ├── sites/ # Конфиги сайтов
│ ├── snippets/ # Сниппеты
│ └── ssl/ # SSL сертификаты
├── logs/ # Логи
├── certbot/ # Certbot
├── scripts/ # Скрипты управления
└── apps/ # Примеры приложений


## 🚀 Быстрый старт

1. **Инициализация SSL**:
   ```bash
   ./scripts/init-ssl.sh
Запуск системы:

bash
./scripts/start.sh
Добавление сайта:

bash
./scripts/add-site.sh myapp 3000
⚡ Скрипты управления
./scripts/start.sh - Запуск

./scripts/stop.sh - Остановка

./scripts/restart.sh - Перезапуск

./scripts/reload.sh - Reload конфигурации

./scripts/status.sh - Статус сервисов

./scripts/logs.sh - Логи

./scripts/add-site.sh domain port - Добавить сайт

./scripts/remove-site.sh domain - Удалить сайт

./scripts/check-config.sh - Проверить конфигурацию

🌐 Пример использования
bash
# Добавляем React приложение на порту 3000
./scripts/add-site.sh reactapp 3000

# Добавляем API на порту 8000
./scripts/add-site.sh myapi 8000

# Проверяем конфигурацию
./scripts/check-config.sh
🔧 Настройка DNS
Добавьте в /etc/hosts для тестирования:

127.0.0.1 frontend.com
127.0.0.1 api.com
127.0.0.1 reactapp.com
127.0.0.1 myapi.com
📝 Примечания
Система проксирует запросы на 127.0.0.1:PORT

Для продакшена замените тестовые SSL сертификаты

Все конфиги автоматически перезагружаются

Логи доступны в logs/nginx/

🐛 Troubleshooting
Проверить конфигурацию:

bash
./scripts/check-config.sh
docker compose logs nginx
Проверить проксирование:

bash
curl -H "Host: frontend.com" http://localhost
<br><br><br>
---
<br><br><br>

# Let's Encrypt Integration

Полная интеграция с Let's Encrypt для автоматического получения и обновления SSL сертификатов.

## Быстрый старт

### Способ 1: Добавление нового сайта с Let's Encrypt
```bash
./scripts/add-site-le.sh myapp 3000 my@email.com
Способ 2: Миграция существующего сайта
bash
./scripts/migrate-to-letsencrypt.sh myapp my@email.com
Способ 3: Ручная настройка
bash
# 1. Добавить сайт (создаст self-signed)
./scripts/add-site.sh myapp 3000

# 2. Мигрировать на Let's Encrypt
./scripts/migrate-to-letsencrypt.sh myapp my@email.com
Скрипты управления
./scripts/setup-letsencrypt.sh <domain> [email] - Настройка Let's Encrypt для домена

./scripts/migrate-to-letsencrypt.sh <domain> [email] - Миграция с self-signed

./scripts/check-certs.sh - Проверка статуса сертификатов

./scripts/force-renew.sh - Принудительное обновление

./scripts/add-site-le.sh <domain> <port> [email] - Добавить сайт с Let's Encrypt

Требования
DNS настройки: Домен должен указывать на IP сервера

Открытые порты: 80 и 443 должны быть доступны извне

Email: Для уведомлений от Let's Encrypt (опционально)

Troubleshooting
Проверить статус автообновления:
bash
docker compose logs certbot
Проверить сроки действия:
bash
./scripts/check-certs.sh
Принудительное обновление:
bash
./scripts/force-renew.sh
Структура сертификатов
text
/home/nginx/certbot/conf/
└── live/
    └── domain.com/
        ├── fullchain.pem
        ├── privkey.pem
        ├── chain.pem
        └── cert.pem
Важно
Let's Encrypt имеет лимиты (50 сертификатов в неделю на домен)

Для тестирования используйте staging окружение

Автообновление работает каждые 12 часов
