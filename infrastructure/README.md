Запуск полного стека:

# Создать сеть и volumes
make network

# Запустить все сервисы
make up-all

# Или поэтапно
make up-base      # Постгрес и сеть
make up-ml        # ClearML стек
make up-monitoring # ELK мониторинг



Запуск только ML стека:

make up-ml

# Доступ к ClearML
open http://localhost:8008




Запуск только CI/CD:

make up-ci

# Доступ к Jenkins
open http://localhost:8080

# Доступ к GitLab
open http://localhost:8082


Мониторинг логов:

# Логи ClearML
make logs-clearml

# Логи ELK
make logs-elk

# Логи Jenkins
make logs-jenkins


Остановка сервисов:

# Остановить все
make down-all

# Или остановить конкретные сервисы
docker-compose -f docker-composes/docker-compose.clearml.yml down


Преимущества такого подхода

    Гибкость: Запускайте только нужные сервисы

    Изоляция: Проблемы в одном сервисе не влияют на другие

    Масштабируемость: Легко добавлять новые сервисы

    Миграция в K8s: Каждый файл → отдельный Helm chart

    Разработка: Разные команды могут работать параллельно

Такой подход идеально подходит для разработки и последующей миграции в Kubernetes!


🚀 Примеры использования Label Studio
Запуск Label Studio:
bash

# Только Label Studio с зависимостями
make up-label-studio

# Или полный стек
make up-all

Доступ к Label Studio:

    Web Interface: http://localhost:8080

    Username: admin@example.com

    Password: labelstudio123

Интеграция с MinIO:

    Загрузка данных в MinIO:

bash

# Загрузка изображений для разметки
mc cp -r ./datasets/images/ minio/label-studio-data/media/

    Настройка подключения в Label Studio:

        Storage Type: S3 Compatible Storage

        Bucket: label-studio-data

        Endpoint: http://minio:9000

        Access Key: minioadmin

        Secret Key: minioadmin

    Экспорт размеченных данных:

bash

# Скачивание размеченных данных
mc cp -r minio/label-studio-data/export/ ./labeled-datasets/

💡 Преимущества Label Studio в MLOps стеке
Для разметчиков:

    🎯 Простой интерфейс для разметки изображений, текста, видео

    👥 Командная работа с назначением задач

    📊 Контроль качества разметки

    ⚡ Быстрая навигация по данным

Для Data Scientists:

    🔄 Экспорт в форматы COCO, YOLO, Pascal VOC, CSV

    📝 Интеграция с DVC для версионирования разметки

    🚀 API для автоматизации процесса разметки

    📈 Статистика и метрики качества разметки

Для MLOps:

    🐳 Docker контейнеризация

    💾 Хранение данных в MinIO (S3 compatible)

    🗄️ База данных в PostgreSQL для метаданных

    🔗 Интеграция с ClearML для тренировки моделей



