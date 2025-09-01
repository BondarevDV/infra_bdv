1. Базовый вариант: Сканирование внешних образов

Этот compose-файл просто запускает контейнер с Trivy, который сканирует указанный образ (например, nginx:alpine) и завершает работу.
yaml

version: '3.8'

services:
  trivy-scanner:
    image: aquasec/trivy:latest
    container_name: trivy-scanner
    # Команда по умолчанию: сканируем образ nginx:alpine
    command: image nginx:alpine
    # Чтобы сканировать другой образ, переопределите command при запуске:
    # docker-compose run trivy-scanner image redis:latest
    volumes:
      # Кеширует базу уязвимостей между запусками для ускорения работы
      - trivy-cache:/root/.cache/
    # Завершаем работу контейнера после выполнения сканирования (restart: no)
    restart: "no"

volumes:
  trivy-cache:
    driver: local

Как использовать:

    Сохраните код выше в файл docker-compose.yml.

    Запустите сканирование образа по умолчанию (nginx:alpine):
    bash

docker-compose up

Чтобы просканировать любой другой образ, используйте run:
bash

    docker-compose run trivy-scanner image redis:latest
    docker-compose run trivy-scanner image python:3.9-slim
    docker-compose run trivy-scanner image my-registry.com/my-app:latest

2. Вариант для сканирования локальных файлов (например, CI/CD)

Этот вариант полезен, если вам нужно просканировать файлы в вашей рабочей директории (например, requirements.txt, package.json) или сгенерировать SBOM.
yaml

version: '3.8'

services:
  trivy-fs-scan:
    image: aquasec/trivy:latest
    container_name: trivy-fs-scanner
    # Меняем рабочую директорию на /app, куда мы смонтируем наш код
    working_dir: /app
    # Команда по умолчанию: сканируем файловую систему текущей директории на уязвимости
    command: fs --security-checks vuln /app
    volumes:
      - .:/app  # Монтируем текущую директорию в контейнер
      - trivy-cache:/root/.cache/
    restart: "no"

volumes:
  trivy-cache:
    driver: local

Как использовать:

    Перейдите в директорию с вашим проектом (где находится Dockerfile, package.json и т.д.).

    Запустите:
    bash

docker-compose run trivy-fs-scan

Примеры других полезных команд для этого контейнера:
bash

    # Сгенерировать SBOM (Software Bill of Materials) в формате JSON
    docker-compose run trivy-fs-scan fs --format cyclonedx /app

    # Проверить только на критические уязвимости
    docker-compose run trivy-fs-scan fs --severity CRITICAL /app

    # Проверить Dockerfile на лучшие практики
    docker-compose run trivy-fs-scan config /app

3. Продвинутый вариант: Серверный режим (Trivy Server)

Trivy можно запустить в режиме сервера, чтобы не скачивать базу уязвимостей при каждом запуске. Это идеально для частого использования в CI.
yaml

version: '3.8'

services:
  trivy-server:
    image: aquasec/trivy:latest
    container_name: trivy-server
    command: server --listen 0.0.0.0:4954
    ports:
      - "4954:4954"  # Пробрасываем порт сервера на хост
    volumes:
      - trivy-cache:/root/.cache/
    # Сервер должен работать постоянно
    restart: unless-stopped

  trivy-client:
    image: aquasec/trivy:latest
    container_name: trivy-client
    # Клиент использует серверный режим и обращается к серверу trivy-server
    command: client --remote http://trivy-server:4954 nginx:alpine
    depends_on:
      - trivy-server
    volumes:
      # Кеш на клиенте не нужен, т.к. он использует сервер
      - /dev/null:/root/.cache/trivy/db.tar.gz # Пустой файл, чтобы отключить кеш
    restart: "no"

volumes:
  trivy-cache:
    driver: local

Как использовать:

    Запустите сервер:
    bash

docker-compose up -d trivy-server

Сервер запустится в фоновом режиме и начнет загружать/обновлять базы уязвимостей.

Запустите клиент для сканирования:
bash

docker-compose run trivy-client

Или, если сервер запущен на другом хосте:
bash

    docker run --rm aquasec/trivy:latest client --remote http://your-server-ip:4954 nginx:alpine

Ключевые моменты:

    Кеш (trivy-cache): Обязательно используйте том для кеша. Это значительно ускорит последующие запуски, так как Trivy не будет каждый раз качать всю базу уязвимостей заново.

    Гибкость: Используйте docker-compose run <service> <новая команда>, чтобы легко менять цель сканирования без редактирования compose-файла.

    Форматы вывода: Добавьте флаги --format json, --format sarif или --exit-code 1 для интеграции с другими системами.
    yaml

command: image --format json --exit-code 1 nginx:alpine

Проверка конфигураций: Trivy умеет сканировать не только на уязвимости, но и на проблемы в конфигурациях (Kubernetes manifests, Dockerfile, Terraform). Используйте субкоманду config:
bash

docker-compose run trivy-scanner config --exit-code 1 /app