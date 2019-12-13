#!/bin/bash -e
# DOMJudge stop script
# Author: Raul Martin <raul.martin@urjc.es>

docker-compose down -f domjudge/docker-compose.yml
