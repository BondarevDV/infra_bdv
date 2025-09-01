
    version: "3.3": Указывает версию Docker-compose, которую вы используете. Версия 3.3 подходит для большинства современных приложений.
    services: В этой секции описываются запускаемые сервисы. 
    twportainer: Имя сервиса. Используется в качестве идентификатора.
    image: portainer/portainer-ce:latest: Определяет образ, который будет использоваться. Здесь используется последняя версия Community Edition.
    container_name: twportainer: Назначает имя контейнера, чтобы было легче его идентифицировать.
    environment: Позволяет задать переменные окружения. Например, - TZ=Europe/Moscow устанавливает временную зону контейнера.
    volumes:

        /var/run/docker.sock:/var/run/docker.sock позволяет Portainer взаимодействовать с Docker на вашем хосте;

        /opt/twportainer/portainer_data:/data создает постоянное хранилище данных.
    ports:

        "8000:8000" и "9443:9443" открывают соответствующие порты для доступа к Portainer. 9443 используется для HTTPS подключения.
    restart: always: Гарантирует, что контейнер будет автоматически перезапускаться при необходимости, например, после перезагрузки сервера.

========================

Эта команда запустит агент Portainer, позволяя Portainer Server подключаться к серверу и управлять контейнерами.

docker run -d \
-p 9001:9001 \
--name portainer_agent \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /var/lib/docker/volumes:/var/lib/docker/volumes \
portainer/agent:2.19.4
