#!/bin/bash -e
# DOMJudge start script
# Author: Raul Martin <raul.martin@urjc.es>

if (( $# != 1 )); then
    echo "Usage: start.sh nJudges, example: ./start.sh 4"
    exit -1
fi

docker-compose pull -f domjudge/docker-compose.yml
docker-compose up --scale jh=$1 -d -f domjudge/docker-compose.yml