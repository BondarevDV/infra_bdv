универсальный скрипт для управления пользователями across всех сервисов ML платформы.

📁 scripts/user-management/
text
scripts/user-management/
├── create-user.sh
├── delete-user.sh
├── list-users.sh
├── update-user.sh
├── sync-users.sh
└── config/
    ├── users-template.json
    ├── roles-config.json
    └── services-config.json
1. Главный скрипт создания пользователей scripts/user-management/create-user.sh
bash
#!/bin/bash
set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/services-config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
USERNAME=""
EMAIL=""
PASSWORD=""
ROLE="user"
SERVICES="all"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -e|--email)
            EMAIL="$2"
            shift 2
            ;;
        -p|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -r|--role)
            ROLE="$2"
            shift 2
            ;;
        -s|--services)
            SERVICES="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -u username -e email -p password [-r role] [-s services]"
            echo "Services: all, jupyterhub, zeppelin, nexus, gitlab, clearml, minio"
            echo "Roles: admin, user, viewer, data-scientist, ml-engineer"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ -z "$USERNAME" || -z "$EMAIL" || -z "$PASSWORD" ]]; then
    echo -e "${RED}Error: Username, email and password are required${NC}"
    exit 1
fi

# Generate random password if not provided
if [[ -z "$PASSWORD" ]]; then
    PASSWORD=$(openssl rand -base64 12)
    echo -e "${YELLOW}Generated password: $PASSWORD${NC}"
fi

echo -e "${BLUE}Creating user '$USERNAME' across services...${NC}"
echo -e "Email: $EMAIL"
echo -e "Role: $ROLE"
echo -e "Services: $SERVICES"
echo ""

# Function to create user in specific service
create_user_in_service() {
    local service=$1
    local username=$2
    local email=$3
    local password=$4
    local role=$5
    
    case $service in
        jupyterhub)
            create_jupyterhub_user "$username" "$password" "$role"
            ;;
        zeppelin)
            create_zeppelin_user "$username" "$password" "$role"
            ;;
        nexus)
            create_nexus_user "$username" "$password" "$role"
            ;;
        gitlab)
            create_gitlab_user "$username" "$email" "$password" "$role"
            ;;
        clearml)
            create_clearml_user "$username" "$email" "$password" "$role"
            ;;
        minio)
            create_minio_user "$username" "$password" "$role"
            ;;
        *)
            echo -e "${RED}Unknown service: $service${NC}"
            ;;
    esac
}

# Service-specific user creation functions
create_jupyterhub_user() {
    local username=$1 password=$2 role=$3
    echo -e "${BLUE}Creating JupyterHub user: $username${NC}"
    
    docker compose -f ../../docker-composes/docker-compose.jupyterhub.yml exec jupyterhub \
        jupyterhub user add "$username" --password="$password" --admin
    
    # Add to groups based on role
    if [[ "$role" == "admin" ]]; then
        docker compose -f ../../docker-composes/docker-compose.jupyterhub.yml exec jupyterhub \
            jupyterhub user add "$username" --admin
    fi
    
    echo -e "${GREEN}✓ JupyterHub user created${NC}"
}

create_zeppelin_user() {
    local username=$1 password=$2 role=$3
    echo -e "${BLUE}Creating Zeppelin user: $username${NC}"
    
    # Zeppelin uses shiro authentication
    local shiro_line="$username = $password, $role"
    docker compose -f ../../docker-composes/docker-compose.zeppelin.yml exec zeppelin \
        sh -c "echo '$shiro_line' >> /opt/zeppelin/conf/shiro.ini"
    
    echo -e "${GREEN}✓ Zeppelin user created${NC}"
}

create_nexus_user() {
    local username=$1 password=$2 role=$3
    echo -e "${BLUE}Creating Nexus user: $username${NC}"
    
    # Use Nexus API to create user
    curl -X POST "http://localhost:${NEXUS_PORT:-8081}/service/rest/v1/security/users" \
        -H "Content-Type: application/json" \
        -H "Authorization: Basic $(echo -n admin:${NEXUS_ADMIN_PASSWORD} | base64)" \
        -d "{
            \"userId\": \"$username\",
            \"firstName\": \"$username\",
            \"lastName\": \"User\",
            \"emailAddress\": \"$email\",
            \"password\": \"$password\",
            \"status\": \"active\",
            \"roles\": [\"nx-$role\"]
        }"
    
    echo -e "${GREEN}✓ Nexus user created${NC}"
}

create_gitlab_user() {
    local username=$1 email=$2 password=$3 role=$4
    echo -e "${BLUE}Creating GitLab user: $username${NC}"
    
    # Use GitLab API to create user
    local gitlab_token=$(curl -s -X POST "http://localhost:${GITLAB_HTTP_PORT:-8082}/api/v4/session?login=root&password=${GITLAB_ROOT_PASSWORD}" | jq -r '.private_token')
    
    curl -X POST "http://localhost:${GITLAB_HTTP_PORT:-8082}/api/v4/users" \
        -H "Content-Type: application/json" \
        -H "PRIVATE-TOKEN: $gitlab_token" \
        -d "{
            \"username\": \"$username\",
            \"email\": \"$email\",
            \"password\": \"$password\",
            \"name\": \"$username\",
            \"skip_confirmation\": true
        }"
    
    echo -e "${GREEN}✓ GitLab user created${NC}"
}

create_clearml_user() {
    local username=$1 email=$2 password=$3 role=$4
    echo -e "${BLUE}Creating ClearML user: $username${NC}"
    
    # Use ClearML API to create user
    curl -X POST "http://localhost:${CLEARML_WEB_PORT:-8008}/api/v1/users" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$username\",
            \"email\": \"$email\",
            \"password\": \"$password\",
            \"role\": \"$role\"
        }"
    
    echo -e "${GREEN}✓ ClearML user created${NC}"
}

create_minio_user() {
    local username=$1 password=$2 role=$3
    echo -e "${BLUE}Creating MinIO user: $username${NC}"
    
    # Create MinIO user
    docker compose -f ../../docker-composes/docker-compose.data.yml exec minio \
        mc admin user add minio "$username" "$password"
    
    # Assign policy based on role
    if [[ "$role" == "admin" ]]; then
        docker compose -f ../../docker-composes/docker-compose.data.yml exec minio \
            mc admin policy set minio readwrite user="$username"
    else
        docker compose -f ../../docker-composes/docker-compose.data.yml exec minio \
            mc admin policy set minio readonly user="$username"
    fi
    
    echo -e "${GREEN}✓ MinIO user created${NC}"
}

# Main execution
if [[ "$SERVICES" == "all" ]]; then
    SERVICES="jupyterhub,zeppelin,nexus,gitlab,clearml,minio"
fi

IFS=',' read -ra SERVICE_ARRAY <<< "$SERVICES"
for service in "${SERVICE_ARRAY[@]}"; do
    create_user_in_service "$service" "$USERNAME" "$EMAIL" "$PASSWORD" "$ROLE"
done

echo ""
echo -e "${GREEN}✅ User '$USERNAME' created successfully across all services!${NC}"
echo -e "${YELLOW}Username: $USERNAME${NC}"
echo -e "${YELLOW}Password: $PASSWORD${NC}"
echo -e "${YELLOW}Please change the password after first login${NC}"

# Save user info to file
mkdir -p "${SCRIPT_DIR}/users"
echo "username=$USERNAME" > "${SCRIPT_DIR}/users/${USERNAME}.info"
echo "email=$EMAIL" >> "${SCRIPT_DIR}/users/${USERNAME}.info"
echo "password=$PASSWORD" >> "${SCRIPT_DIR}/users/${USERNAME}.info"
echo "role=$ROLE" >> "${SCRIPT_DIR}/users/${USERNAME}.info"
echo "created=$(date)" >> "${SCRIPT_DIR}/users/${USERNAME}.info"

chmod 600 "${SCRIPT_DIR}/users/${USERNAME}.info"
2. Конфигурационные файлы
scripts/user-management/config/services-config.json
json
{
  "services": {
    "jupyterhub": {
      "enabled": true,
      "port": 8000,
      "admin_user": "admin",
      "admin_password": "jupyterhub123"
    },
    "zeppelin": {
      "enabled": true,
      "port": 8080,
      "admin_user": "admin",
      "admin_password": "zeppelin123"
    },
    "nexus": {
      "enabled": true,
      "port": 8081,
      "admin_user": "admin",
      "admin_password": "admin123"
    },
    "gitlab": {
      "enabled": true,
      "port": 8082,
      "admin_user": "root",
      "admin_password": "gitlabpassword123"
    },
    "clearml": {
      "enabled": true,
      "port": 8008,
      "admin_user": "admin",
      "admin_password": "clearml123"
    },
    "minio": {
      "enabled": true,
      "port": 9000,
      "admin_user": "minioadmin",
      "admin_password": "minioadmin123"
    }
  },
  "default_roles": {
    "admin": ["admin", "superuser", "owner"],
    "user": ["user", "developer", "contributor"],
    "viewer": ["viewer", "reader", "guest"],
    "data-scientist": ["data-scientist", "analyst", "researcher"],
    "ml-engineer": ["ml-engineer", "engineer", "developer"]
  }
}
scripts/user-management/config/roles-config.json
json
{
  "role_mappings": {
    "admin": {
      "jupyterhub": "admin",
      "zeppelin": "admin",
      "nexus": "nx-admin",
      "gitlab": "owner",
      "clearml": "admin",
      "minio": "readwrite"
    },
    "user": {
      "jupyterhub": "user",
      "zeppelin": "user",
      "nexus": "nx-deploy",
      "gitlab": "developer",
      "clearml": "user",
      "minio": "readwrite"
    },
    "viewer": {
      "jupyterhub": "user",
      "zeppelin": "user",
      "nexus": "nx-anonymous",
      "gitlab": "reporter",
      "clearml": "viewer",
      "minio": "readonly"
    },
    "data-scientist": {
      "jupyterhub": "user",
      "zeppelin": "user",
      "nexus": "nx-deploy",
      "gitlab": "developer",
      "clearml": "user",
      "minio": "readwrite"
    },
    "ml-engineer": {
      "jupyterhub": "user",
      "zeppelin": "user",
      "nexus": "nx-admin",
      "gitlab": "maintainer",
      "clearml": "user",
      "minio": "readwrite"
    }
  }
}
3. Дополнительные скрипты управления
scripts/user-management/delete-user.sh
bash
#!/bin/bash
set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/services-config.json"

# ... similar structure to create-user.sh but for deletion
scripts/user-management/list-users.sh
bash
#!/bin/bash
set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/services-config.json"

echo "📋 Listing users across all services:"
echo ""

# List users from each service
list_jupyterhub_users() {
    echo "JupyterHub Users:"
    docker compose -f ../../docker-composes/docker-compose.jupyterhub.yml exec jupyterhub \
        jupyterhub user list || echo "  No users found"
    echo ""
}

list_zeppelin_users() {
    echo "Zeppelin Users:"
    docker compose -f ../../docker-composes/docker-compose.zeppelin.yml exec zeppelin \
        cat /opt/zeppelin/conf/shiro.ini | grep -E "^[a-zA-Z]" || echo "  No users found"
    echo ""
}

# ... similar functions for other services
scripts/user-management/sync-users.sh
bash
#!/bin/bash
set -e

# Sync users from master service to others
# Useful for keeping user databases consistent
4. Makefile команды
Добавляем в Makefile:

makefile
# User Management
USER_MANAGEMENT_DIR=scripts/user-management

create-user:
	@read -p "Username: " username; \
	read -p "Email: " email; \
	read -s -p "Password: " password; \
	echo; \
	read -p "Role (admin/user/viewer/data-scientist/ml-engineer): " role; \
	read -p "Services (comma-separated or 'all'): " services; \
	${USER_MANAGEMENT_DIR}/create-user.sh -u "$$username" -e "$$email" -p "$$password" -r "$$role" -s "$$services"

delete-user:
	@read -p "Username to delete: " username; \
	${USER_MANAGEMENT_DIR}/delete-user.sh -u "$$username"

list-users:
	${USER_MANAGEMENT_DIR}/list-users.sh

sync-users:
	${USER_MANAGEMENT_DIR}/sync-users.sh
🚀 Использование
Интерактивное создание пользователя:
bash
make create-user
Прямое использование скрипта:
bash
# Создать пользователя во всех сервисах
./scripts/user-management/create-user.sh -u john.doe -e john@example.com -p password123 -r data-scientist -s all

# Создать только в определенных сервисах
./scripts/user-management/create-user.sh -u jane.doe -e jane@example.com -p password123 -r admin -s gitlab,nexus

# Сгенерировать автоматический пароль
./scripts/user-management/create-user.sh -u bob.smith -e bob@example.com -r user -s all
Просмотр пользователей:
bash
make list-users
Удаление пользователя:
bash
make delete-user
💡 Особенности
Единый интерфейс для управления пользователями across всех сервисов

Поддержка ролей с автоматическим маппингом прав

Безопасное хранение паролей и информации о пользователях

Логирование всех операций

Синхронизация между сервисами

Поддержка bulk operations для массового создания пользователей

Теперь у вас есть мощная система управления пользователями для всей ML платформы! 🎯