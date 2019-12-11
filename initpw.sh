#!/bin/bash
# Init pws
# Author: Raul Martin <raul.martin@urjc.es>

echo "--> Writing configurations..."
sleep 1
cp domjudge-template/docker-compose.yml domjudge/docker-compose.yml


# Random password for judgehost
jdpw=$(openssl rand -hex 12)
sed -i "s/JUDGEDAEMON_PASSWORD=password/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml

# Replace default password with user provided values
sed -i "s/MYSQL_ROOT_PASSWORD=domjudge/MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_PASSWORD=domjudge/MYSQL_PASSWORD=$MYSQL_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_USER=domjudge/MYSQL_USER=$MYSQL_USER/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_DATABASE=domjudge/MYSQL_DATABASE=$MYSQL_DATABASE/g" domjudge/docker-compose.yml
sed -i "s/JUDGEDAEMON_PASSWORD=domjudge/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml
echo "$jdpw" >domjudge/judgehost_password