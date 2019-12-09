#!/bin/bash
# Author: Raul Martin <raul.martin@urjc.es>

curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
docker stack deploy --compose-file=portainer-agent-stack.yml portainer
