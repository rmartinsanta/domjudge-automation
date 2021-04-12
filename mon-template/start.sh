#!/bin/bash -e
# Monitoring stack start script
# Author: Raul Martin <raul.martin@urjc.es>

docker-compose pull
docker-compose up -d --build
echo ">> Monitoring stack is starting, Grafana listening on port 1337. Allow some minutes to complete initialization"
