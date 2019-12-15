#!/bin/bash -e
# Set DAEMON_ID
# Author: Raul Martin <raul.martin@urjc.es>

hname=$(hostname)
echo "Hostname: $hname"
myname=$(docker inspect --format={{.Name}} $hname)
echo "My name: $myname"
id="${myname: -1}"
idlinux="$(($id-1))"
echo "Id: $id, idlinux: $idlinux"
export DAEMON_ID=$idlinux
exec "$@"