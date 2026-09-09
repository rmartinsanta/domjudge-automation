#!/bin/bash -e
# DOMJudge start script
# Author: Raul Martin <raul.martin@urjc.es>

if (( $# != 1 )); then
    echo "Usage: start.sh nJudges, example: ./start.sh 4"
    echo "First time launch with 0, configure judgehost password and then launch start.sh again"
    exit -1
fi

if [ ! -d "domjudge" ]; then
  echo "domjudge directory does not exist. Please, execute ./install.sh before starting DOMJudge."
fi
cd domjudge
docker compose pull
docker compose up --scale jh=$1 -d

echo ">> Containers are starting, allow some minutes to complete initialization"
