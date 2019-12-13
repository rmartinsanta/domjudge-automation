#!/bin/bash -e
# DOMJudge stop script
# Author: Raul Martin <raul.martin@urjc.es>

docker-compose logs -f domjudge/docker-compose.yml
