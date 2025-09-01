.PHONY: help network volumes up down logs ps clean purge

help:
	@echo "DevOps Infrastructure Management"
	@echo ""
	@echo "Commands:"
	@echo "  make network          - Create Docker network"
	@echo "  make volumes          - Create Docker volumes"
	@echo "  make up-all           - Start all services"
	@echo "  make up-base          - Start base services"
	@echo "  make up-ml            - Start ML stack (Postgres + ClearML)"
	@echo "  make up-monitoring    - Start monitoring (ELK)"
	@echo "  make up-ci            - Start CI/CD (Jenkins + GitLab + Nexus + SonarQube)"
	@echo "  make up-data          - Start data services (MinIO + LakeFS)"
	@echo "  make down-all         - Stop all services"
	@echo "  make down-%           - Stop specific service"
	@echo "  make logs-%           - View logs for service"
	@echo "  make ps               - Show running containers"
	@echo "  make clean            - Stop services and remove containers"
	@echo "  make purge            - Stop services and remove containers, volumes, network"

# Создание сети
network:
	@docker network create ${NETWORK_NAME} 2>/dev/null || true
	@echo "Network ${NETWORK_NAME} created/verified"

# Создание volumes
volumes:
	@docker volume create postgres_data 2>/dev/null || true
	@docker volume create elasticsearch_data 2>/dev/null || true
	@docker volume create logstash_data 2>/dev/null || true
	@docker volume create kibana_data 2>/dev/null || true
	@docker volume create filebeat_data 2>/dev/null || true
	@docker volume create clearml_storage 2>/dev/null || true
	@docker volume create jenkins_data 2>/dev/null || true
	@docker volume create nexus_data 2>/dev/null || true
	@docker volume create sonarqube_data 2>/dev/null || true
	@docker volume create sonarqube_extensions 2>/dev/null || true
	@docker volume create sonarqube_logs 2>/dev/null || true
	@docker volume create gitlab_config 2>/dev/null || true
	@docker volume create gitlab_logs 2>/dev/null || true
	@docker volume create gitlab_data 2>/dev/null || true
	@docker volume create agent-workspace 2>/dev/null || true
	@docker volume create lakefs_storage 2>/dev/null || true
	@docker volume create minio_data 2>/dev/null || true
	@docker volume create redis_data 2>/dev/null || true
	@echo "All volumes created/verified"

# Полный запуск
up-all: network volumes
	@echo "Starting all services..."
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	up -d
	@echo "All services started. Run 'make ps' to check status"

# Базовые сервисы
up-base: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	up -d

# ML стек
up-ml: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	up -d

# Мониторинг
up-monitoring: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.elk.yml \
	up -d

# CI/CD
up-ci: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	up -d

# Data services
up-data: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.data.yml \
	up -d

# Остановка всех
down-all:
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	down

# Остановка конкретного сервиса
down-%:
	docker-compose -f docker-composes/docker-compose.$*.yml down

# Логи
logs-%:
	docker-compose -f docker-composes/docker-compose.$*.yml logs -f

# Статус
ps:
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	-f docker-composes/docker-compose.label-studio.yml \
	up -d

# Очистка
clean: down-all
	@echo "Stopped all services"

# Добавляем в очистку
purge: down-all
	@docker network rm ${NETWORK_NAME} 2>/dev/null || true
	@docker volume rm -f postgres_data elasticsearch_data logstash_data kibana_data filebeat_data clearml_storage jenkins_data nexus_data sonarqube_data sonarqube_extensions sonarqube_logs gitlab_config gitlab_logs gitlab_data agent-workspace lakefs_storage minio_data redis_data label_studio_data label_studio_media 2>/dev/null || true
	@echo "Removed all containers, volumes and network"