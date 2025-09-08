# Load environment variables
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

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
	@echo "	 Spark HA Cluster Management:"
	@echo "  make up-spark-ha          - Start Spark HA cluster"
	@echo "  make down-spark-ha        - Stop Spark HA cluster"
	@echo "  make restart-spark-ha     - Restart Spark HA cluster"
	@echo "  make scale-spark-workers  - Scale number of Spark workers"
	@echo "  make spark-status         - Show Spark cluster status"
	@echo "  make spark-logs           - Show Spark master logs"
	@echo "  make spark-shell          - Start Spark shell session"
	@echo "  make livy-sessions        - List active Livy sessions"
	@echo "  make spark-monitor        - Open monitoring dashboards"
	@echo "  make test-spark-ha        - Test Spark HA functionality"
	@echo "  make up-all-with-spark    - Start complete platform with Spark HA"

	

test-spark-ha:
	@echo "Testing Spark HA Cluster..."
	@./scripts/spark/test-ha.sh


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
	@docker volume create zeppelin_data 2>/dev/null || true
	@docker volume create zeppelin_interpreter 2>/dev/null || true
	@docker volume create 	zookeeper_data 2>/dev/null || true
	@docker volume create 	spark_data 2>/dev/null || true
	@docker volume create 	spark_logs 2>/dev/null || true
	@docker volume create  	spark_jars 2>/dev/null || true
	@docker volume create 	prometheus_data 2>/dev/null || true
	@docker volume create 	grafana_data 2>/dev/null || true
	@docker volume create 	keycloak_data 2>/dev/null || true
	@docker volume create 	jupyterhub_data 2>/dev/null || true
	@docker volume create 	jupyterhub_db_data 2>/dev/null || true
	@docker volume create 	label_studio_data 2>/dev/null || true
	@docker volume create 	label_studio_media 2>/dev/null || true
	@echo "All volumes created/verified"

# Полный запуск
up-all: network volumes
	@echo "Starting all services..."
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	-f docker-composes/docker-compose.label-studio.yml \
	-f docker-composes/docker-compose.jupyterhub.yml \
	-f docker-composes/docker-compose.zeppelin.yml \
	-f docker-composes/docker-compose.keycloak.yml \
	-f docker-composes/docker-compose.spark-ha.yml \
	up -d
	@echo "All services started. Run 'make ps' to check status"

# Базовые сервисы
up-base: network volumes
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	up -d

# ML стек
up-ml: network volumes
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	up -d

# Мониторинг
up-monitoring: network volumes
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.elk.yml \
	up -d

# CI/CD
up-ci: network volumes
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	up -d

# Data services
up-data: network volumes
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.data.yml \
	up -d

# Data Analitics
up-zeppelin: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.zeppelin.yml \
	up -d


up-jupyterhub: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.jupyterhub.yml \
	up -d

# Добавляем команды для Keycloak
up-keycloak: network volumes
	docker-compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.keycloak.yml \
	up -d


# Остановка всех
down-all:
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	-f docker-composes/docker-compose.label-studio.yml \
	-f docker-composes/docker-compose.jupyterhub.yml \
	-f docker-composes/docker-compose.zeppelin.yml \
	-f docker-composes/docker-compose.keycloak.yml \
	-f docker-composes/docker-compose.spark-ha.yml \
	down

# Остановка конкретного сервиса
down-%:
	docker compose -f docker-composes/docker-compose.$*.yml down

# Логи
logs-%:
	docker compose -f docker-composes/docker-compose.$*.yml logs -f

# Статус
ps:
	docker compose -f docker-composes/docker-compose.base.yml \
	-f docker-composes/docker-compose.postgres.yml \
	-f docker-composes/docker-compose.clearml.yml \
	-f docker-composes/docker-compose.elk.yml \
	-f docker-composes/docker-compose.jenkins.yml \
	-f docker-composes/docker-compose.gitlab.yml \
	-f docker-composes/docker-compose.nexus.yml \
	-f docker-composes/docker-compose.sonarqube.yml \
	-f docker-composes/docker-compose.data.yml \
	-f docker-composes/docker-compose.label-studio.yml \
	-f docker-composes/docker-compose.jupyterhub.yml \
	-f docker-composes/docker-compose.zeppelin.yml \
	-f docker-composes/docker-compose.keycloak.yml \
	-f docker-composes/docker-compose.spark-ha.yml \
	up -d
# Очистка
clean: down-all
	@echo "Stopped all services"

# Добавляем в очистку
purge: down-all
	@docker network rm ${NETWORK_NAME} 2>/dev/null || true
	@docker volume rm -f postgres_data elasticsearch_data logstash_data kibana_data filebeat_data clearml_storage jenkins_data nexus_data sonarqube_data sonarqube_extensions sonarqube_logs gitlab_config gitlab_logs gitlab_data agent-workspace lakefs_storage minio_data redis_data label_studio_data label_studio_media 2>/dev/null || true
	@echo "Removed all containers, volumes and network"






# Spark High Availability Cluster
SPARK_HA_COMPOSE=-f docker-composes/docker-compose.spark-ha.yml

up-spark-ha: network volumes
	@echo "Starting Spark HA Cluster..."
	docker-compose ${SPARK_HA_COMPOSE} up -d
	@echo "Spark HA Cluster started!"
	@echo "Spark Master UI: http://spark-master-1.dev.tnt.ru:8081"
	@echo "Grafana: http://spark-grafana.dev.tnt.ru:3000 (admin/grafana123)"
	@echo "Livy: http://livy.dev.tnt.ru:8998"

down-spark-ha:
	@echo "Stopping Spark HA Cluster..."
	docker-compose ${SPARK_HA_COMPOSE} down

restart-spark-ha: down-spark-ha up-spark-ha

scale-spark-workers:
	@read -p "Enter number of workers: " workers; \
	docker-compose ${SPARK_HA_COMPOSE} up -d --scale spark-worker=$$workers

spark-status:
	@echo "=== Spark Cluster Status ==="
	@docker-compose ${SPARK_HA_COMPOSE} ps | grep -E "(spark-|zookeeper|livy)"

spark-logs:
	@echo "Showing Spark logs (Ctrl+C to exit)..."
	@docker-compose ${SPARK_HA_COMPOSE} logs -f spark-master-1

spark-shell:
	@echo "Starting Spark Shell..."
	@docker-compose ${SPARK_HA_COMPOSE} exec spark-master-1 spark-shell --master spark://spark-master-1:7077

livy-sessions:
	@echo "Active Livy Sessions:"
	@curl -s http://localhost:8998/sessions | jq .

spark-monitor:
	@echo "Opening Spark Monitoring Dashboard..."
	@echo "Spark Master UI: http://spark-master-1.dev.tnt.ru:8081"
	@echo "Spark History: http://spark-history.dev.tnt.ru:18080"
	@echo "Grafana: http://spark-grafana.dev.tnt.ru:3000"
	@echo "Livy UI: http://livy.dev.tnt.ru:8998/ui"

test-spark-ha:
	@echo "Testing Spark HA Cluster..."
	@./scripts/spark/test-ha.sh

# Полный запуск всей платформы включая Spark HA
up-all-with-spark: network volumes
	@echo "Starting complete ML Platform with Spark HA..."
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
	-f docker-composes/docker-compose.jupyterhub.yml \
	-f docker-composes/docker-compose.zeppelin.yml \
	-f docker-composes/docker-compose.keycloak.yml \
	-f docker-composes/docker-compose.spark-ha.yml \
	up -d
	@echo "Complete ML Platform with Spark HA started!"

# Help информация
help-spark:
	@echo "Spark HA Cluster Management:"
	@echo "  make up-spark-ha          - Start Spark HA cluster"
	@echo "  make down-spark-ha        - Stop Spark HA cluster"
	@echo "  make restart-spark-ha     - Restart Spark HA cluster"
	@echo "  make scale-spark-workers  - Scale number of Spark workers"
	@echo "  make spark-status         - Show Spark cluster status"
	@echo "  make spark-logs           - Show Spark master logs"
	@echo "  make spark-shell          - Start Spark shell session"
	@echo "  make livy-sessions        - List active Livy sessions"
	@echo "  make spark-monitor        - Open monitoring dashboards"
	@echo "  make test-spark-ha        - Test Spark HA functionality"
	@echo "  make up-all-with-spark    - Start complete platform with Spark HA"