FROM openjdk:8-jdk

# Копируем архив Livy в контейнер
COPY apache-livy-0.8.0-incubating_2.11-bin.zip /tmp/

RUN apt-get update && \
    apt-get install -y unzip && \
    unzip /tmp/apache-livy-0.8.0-incubating_2.11-bin.zip -d /opt && \
    mv /opt/apache-livy-0.8.0-incubating_2.11-bin /opt/livy && \
    rm /tmp/apache-livy-0.8.0-incubating_2.11-bin.zip

WORKDIR /opt/livy
CMD ["bin/livy-server"]