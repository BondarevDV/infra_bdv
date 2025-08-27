#!/bin/bash

# Настраиваем docker на kind
kind load docker-image frontend-app:latest --name dev-cluster
kind load docker-image backend-app:latest --name dev-cluster

docker build -t frontend-app:latest ./frontend
docker build -t backend-app:latest ./backend

kind load docker-image frontend-app:latest --name dev-cluster
kind load docker-image backend-app:latest --name dev-cluster