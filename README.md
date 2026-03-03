# 🚀 nginx-template: The KISS Reverse Proxy

Легковесный, производительный и безопасный Docker-стек (Nginx + Certbot) для управления сайтами, SSL-сертификатами и проксированием. 

Идеальная замена Nginx Proxy Manager / Traefik для тех, кто предпочитает терминал, Bash и минимальное потребление ресурсов (Zero Overhead).

![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?style=for-the-badge&logo=nginx&logoColor=white) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Bash](https://img.shields.io/badge/bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

## ✨ Ключевые возможности

- 🪶 **Zero Overhead:** Никаких баз данных и фоновых Node.js процессов для админки. Только голый Nginx в Docker-контейнере.
- 🔐 **Автоматический SSL:** Выпуск и продление сертификатов Let's Encrypt «из коробки» (без даунтайма).
- 🛡️ **Enterprise Security (A+):** Предустановленные заголовки безопасности (HSTS, CSP, X-Frame-Options) и защита от базовых эксплойтов.
- 🖼️ **Image Proxy:** Встроенный ресайз и кроп картинок на лету (через `http_image_filter_module`).
- ⚡ **Умный CDN:** Поднятие кеширующего прокси-узла для статики с S3/MinIO одной командой.
- ☁️ **Cloudflare интеграция:** Автоматическое обновление реальных IP-адресов Cloudflare.

## 🚀 Быстрый старт

### 1. Установка
```bash
git clone https://github.com/Arlandaren/nginx-template.git /opt/nginx
cd /opt/nginx
./manage.sh start
```

### 2. Добавление классического сайта с SSL
Предположим, ваше приложение работает на `3000` порту на этом же сервере.
```bash
# ./manage.sh add <domain> <port> [email]
./manage.sh add example.com 3000 my@email.com
```
Скрипт сам создаст конфиг, запросит сертификат у Let's Encrypt и мягко перезагрузит Nginx. Ваш сайт доступен по HTTPS!

## 🎮 Пульт управления: `manage.sh`

Единая точка входа для всех операций. Больше не нужно запоминать кучу разрозненных скриптов.

### Управление сайтами
| Команда | Описание | Пример |
|---------|----------|--------|
| `add` | Добавить сайт (reverse-proxy) с SSL | `./manage.sh add api.domain.com 8080` |
| `cdn` | Кеширующий прокси (статика) | `./manage.sh cdn static.domain.com https://min.io` |
| `img` | Микросервис ресайза картинок | `./manage.sh img img.domain.com https://s3.aws.com` |
| `remove`| Удалить сайт и его сертификаты | `./manage.sh remove example.com` |
| `health`| Проверить статус всех сайтов | `./manage.sh health` |

### Управление стеком (Nginx + Certbot)
| Команда | Описание |
|---------|----------|
| `start`, `stop`, `restart` | Управление Docker-контейнерами |
| `reload` | Мягкая перезагрузка Nginx (zero-downtime) |
| `status` | Статус контейнеров |
| `logs [-f]` | Просмотр логов Nginx и Certbot |

### Обслуживание и аналитика
| Команда | Описание |
|---------|----------|
| `check-certs` | Проверить сроки действия SSL сертификатов |
| `update-cf-ips` | Обновить список IP Cloudflare (`set_real_ip_from`) |
| `top` | Вывести ТОП активных IP-адресов из логов (анализ трафика) |
| `rotate-logs` | Ручная ротация логов (защита диска от переполнения) |
| `backup` | Создать архив (`.tar.gz`) всех конфигов и SSL-сертификатов |

## 📁 Структура проекта
```text
/opt/nginx/
├── manage.sh           # Главный скрипт-роутер
├── docker-compose.yml  # Декларация контейнеров
├── nginx/
│   ├── nginx.conf      # Глобальные настройки
│   ├── sites/          # Сгенерированные конфиги сайтов
│   ├── snippets/       # Переиспользуемые куски (security.conf, proxy.conf и т.д.)
│   └── templates/      # Шаблоны конфигов (.conf)
├── certbot/            # Директория Let's Encrypt (сертификаты)
├── logs/               # Логи Nginx (access/error)
└── scripts/            # Внутренние bash-скрипты системы
```

## 🧠 Продвинутые фичи

### Изменение размера изображений (Image Proxy)
После вызова команды добавления Image Proxy:
```bash
./manage.sh img media.domain.com https://your-bucket.s3.com
```
Вы можете запрашивать изображения с нужными размерами прямо через URL:
- Оригинал: `https://media.domain.com/photo.jpg`
- Ресайз 800x600: `https://media.domain.com/photo.jpg?w=800&h=600`
- Только ширина 500px: `https://media.domain.com/photo.jpg?w=500`

Nginx автоматически загрузит оригинал с S3 (или любого origins), обрежет его, закеширует результат на диске и отдаст пользователю.

### Cloudflare и реальные IP
Если сервер спрятан за Cloudflare, добавьте в `cron` задачу обновления IP, чтобы Nginx видел реальные IP клиентов, а не адреса нод CF:
```bash
0 0 * * 1 /opt/nginx/manage.sh update-cf-ips > /dev/null 2>&1
```

## 🐛 Решение проблем (Troubleshooting)

1. **Сертификат не выписывается**
   Убедитесь, что ваш домен точно делегирован на IP сервера и в фаерволе открыты порты `80` и `443`.
   Посмотреть логи процесса:
   ```bash
   ./manage.sh logs -f
   ```

2. **Как добавить кастомную настройку Nginx?**
   Все сайты хранятся в `./nginx/sites/`. После добавления сайта через `./manage.sh add`, вы можете отредактировать созданный файл (например, `./nginx/sites/example.com.conf`) в любом консольном редакторе, а затем выполнить перезагрузку:
   ```bash
   ./manage.sh reload
   ```

## 🤝 Контрибьют и Поддержка
Пулл-реквесты категорически приветствуются! 

Если проект сэкономил вам пару часов жизни, кучу оперативной памяти и помог поднять пет-проект — поставьте ⭐️ этому репозиторию. Код должен работать, а звезды — расти.
