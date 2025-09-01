# Инициализация проекта
cd infrastructure
make network
make volumes

# Запуск всего стека
make up-all

# Или выборочный запуск
make up-ml           # Только ML стек
make up-ci           # Только CI/CD
make up-monitoring   # Только мониторинг

# Просмотр логов
make logs-clearml
make logs-jenkins

# Остановка
make down-all
make purge          # Полная очистка