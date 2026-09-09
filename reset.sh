#!/bin/bash -e
# DOMJudge reset script
# Author: Raul Martin <raul.martin@urjc.es>

if (( $# != 1 )); then
    echo "Usage: reset.sh --yes-i-really-want-to-destroy-all-data"
    exit -1
fi

if [ $1 = "--yes-i-really-want-to-destroy-all-data" ]; then
  echo "If you want to reinstall DOMJudge after reset, please run ./install.sh after reset.  I will wait 10 seconds to make sure you are reading this!"
  sleep 10
  ./stop.sh
  sudo rm -rf domjudge
  docker volume rm domjudge_sqldata
  docker system prune -a --volumes
  git pull
else
    echo "Looks like you are not really sure..."
fi
