#!/bin/bash -e
# Init pws
# Author: Raul Martin <raul.martin@urjc.es>

# Need dbname and username for the db
if (( $# != 2 )); then
    echo "initpw.sh must recieve two arguments, dbname and username"
    exit -1
fi

echo "--> Writing configurations..."
sleep 1
mkdir -p domjudge
cp domjudge-template/docker-compose.yml domjudge/docker-compose.yml

# Random passwords generation for all
jdpw=$(openssl rand -hex 16)
MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)
MYSQL_PASSWORD=$(openssl rand -hex 16)
MYSQL_DATABASE=$1
MYSQL_USER=$2

echo "SQL Root Password: $MYSQL_ROOT_PASSWORD"
echo "SQL DB: $1"
echo "SQL Username: $2"
echo "SQL Password: $MYSQL_PASSWORD"
echo "JudgeHost API password: $jdpw"

sed -i "s/JUDGEDAEMON_PASSWORD=password/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml

# Replace default password with user provided values
sed -i "s/MYSQL_ROOT_PASSWORD=domjudge/MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_PASSWORD=domjudge/MYSQL_PASSWORD=$MYSQL_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_USER=domjudge/MYSQL_USER=$MYSQL_USER/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_DATABASE=domjudge/MYSQL_DATABASE=$MYSQL_DATABASE/g" domjudge/docker-compose.yml
sed -i "s/JUDGEDAEMON_PASSWORD=domjudge/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml

sed -i "s/MARIADB_ROOT_PASSWORD=domjudge/MARIADB_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MARIADB_PASSWORD=domjudge/MARIADB_PASSWORD=$MYSQL_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MARIADB_USER=domjudge/MARIADB_USER=$MYSQL_USER/g" domjudge/docker-compose.yml
sed -i "s/MARIADB_DATABASE=domjudge/MARIADB_DATABASE=$MYSQL_DATABASE/g" domjudge/docker-compose.yml
sed -i "s/JUDGEDAEMON_PASSWORD=domjudge/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml
echo "$jdpw" >domjudge/judgehost_password
