# Использование через Livy:
# Создание сессии Livy
curl -X POST -H "Content-Type: application/json" \
  -d '{"kind": "pyspark"}' \
  http://livy.dev.tnt.ru:8998/sessions

# Выполнение кода
curl -X POST -H "Content-Type: application/json" \
  -d '{"code":"sc.parallelize(range(1000)).count()"}' \
  http://livy.dev.tnt.ru:8998/sessions/0/statements