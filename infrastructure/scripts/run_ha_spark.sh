# Запуск всего HA кластера
docker-compose -f docker-composes/docker-compose.spark-ha.yml up -d

# Проверка статуса
./scripts/spark/ha-management.sh status

# Масштабирование воркеров
./scripts/spark/ha-management.sh scale 4

# Тестирование отказоустойчивости
./scripts/spark/ha-management.sh restart-master 1