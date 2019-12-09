#!/bin/bash
# DOMJudge installation script
# Author: Raul Martin <raul.martin@urjc.es>

set -e
echo "DOMJudge installation script v1"

# Check privileges
if [[ $EUID -ne 0 ]]; then
   echo "The installation script must be run as root, change user or try with sudo" 
   exit 1
fi

# Check for a previous installation
if [ -d "domjudge" ]; then
  echo "Domjudge directory already exists, it looks like the installation already took place. If you want to reinstall, delete the domjudge directory first."
  exit 1
fi

# Helper function
error(){
    if [ $? -ne 0 ]; then
        echo "An error has ocurred in the following step: $1"
        exit 1
    fi
}

# Install Docker
chmod +x common/install-docker.sh
common/install-docker.sh 

# Download domjudge source code
## Not necessary anymore, we are using domserver docker image
#git clone https://github.com/DOMjudge/domjudge
#curl "https://raw.githubusercontent.com/DOMjudge/domjudge/master/docker-compose.yml" --#output domjudge/docker-compose.yml
#error "Cloning DOMJudge source code"
#chown -R $username:$username domjudge
#error "Granting privileges to user $username to use DOMJudge"

echo "--> Configuring database...."
read -p "Password for DB root user: " MYSQL_ROOT_PASSWORD
read -p "Database name for DomJudge: " MYSQL_DATABASE
read -p "Database user for DomJudge: " MYSQL_USER
read -p "Database password for DomJudge: " MYSQL_PASSWORD

echo "--> Writing configurations..."
sleep 1
mkdir domjudge
mkdir domjudge/database
echo "
version: '3'

services:
  db:
    image: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=domjudge
      - MYSQL_USER=domjudge
      - MYSQL_PASSWORD=domjudge
      - MYSQL_DATABASE=domjudge
    ports:
      - 3306:3306
    command: --max-connections=1000 --max-allowed-packet=512M
    volumes:
      - ./database:/var/lib/mysql
  domjudge:
    build: ./domserver/
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    ports:
      - 80:80
    environment:
      - MYSQL_HOST=db
      - MYSQL_ROOT_PASSWORD=domjudge
      - MYSQL_USER=domjudge
      - MYSQL_PASSWORD=domjudge
      - MYSQL_DATABASE=domjudge
      - JUDGEDAEMON_USERNAME=judgehost
      - JUDGEDAEMON_PASSWORD=password
  judgehost-0:
    build: ./judgehost/
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    environment:
      - DAEMON_ID=0
      - DOMSERVER_HOST=domjudge
      - DOMSERVER_BASEURL=http://domjudge/
      - JUDGEDAEMON_USERNAME=judgehost
      - JUDGEDAEMON_PASSWORD=domjudge
    privileged: true

" >domjudge/docker-compose.yml

mkdir domjudge/domserver
mkdir domjudge/judgehost

echo '
#!/bin/sh

TIMEOUT=300
QUIET=0

echoerr() {
  if [ "$QUIET" -ne 1 ]; then printf "%s\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $cmdname host:port [-t timeout] [-- command args]
  -q | --quiet                        Do not output any status messages
  -t TIMEOUT | --timeout=timeout      Timeout in seconds, zero for no timeout
  -- COMMAND ARGS                     Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

wait_for() {
  for i in `seq $TIMEOUT` ; do
    nc -z "$HOST" "$PORT" > /dev/null 2>&1
    
    result=$?
    if [ $result -eq 0 ] ; then
      if [ $# -gt 0 ] ; then
        exec "$@"
      fi
      exit 0
    fi
    echo "Testing $HOST:$PORT --> Not ready yet"
    sleep 2
  done
  echo "Operation timed out" >&2
  exit 1
}

while [ $# -gt 0 ]
do
  case "$1" in
    *:* )
    HOST=$(printf "%s\n" "$1"| cut -d : -f 1)
    PORT=$(printf "%s\n" "$1"| cut -d : -f 2)
    shift 1
    ;;
    -q | --quiet)
    QUIET=1
    shift 1
    ;;
    -t)
    TIMEOUT="$2"
    if [ "$TIMEOUT" = "" ]; then break; fi
    shift 2
    ;;
    --timeout=*)
    TIMEOUT="${1#*=}"
    shift 1
    ;;
    --)
    shift
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage 1
    ;;
  esac
done

if [ "$HOST" = "" -o "$PORT" = "" ]; then
  echoerr "Error: you need to provide a host and port to test."
  usage 2
fi

wait_for "$@"

' >domjudge/waitfor.sh
cp domjudge/waitfor.sh domjudge/judgehost/
cp domjudge/waitfor.sh domjudge/domserver/



# Generate custom Dockerfiles

echo '
FROM domjudge/domserver
RUN apt-get update && apt-get install -y netcat
ADD waitfor.sh /scripts/waitfor.sh
RUN chmod +x /scripts/waitfor.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $MYSQL_HOST:3306 -- /scripts/start.sh"]
' >domjudge/domserver/Dockerfile

echo '
FROM domjudge/judgehost
RUN apt-get update && apt-get install -y netcat
ADD waitfor.sh /scripts/waitfor.sh
RUN chmod +x /scripts/waitfor.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $DOMSERVER_HOST:80 -- /scripts/start.sh"]
' >domjudge/judgehost/Dockerfile

echo '
#!/bin/bash
screen -dmS domjudge
screen -S domjudge -X stuff "docker-compose up --build\n"
screen -r domjudge

' >domjudge/start.sh
chmod +x domjudge/start.sh

echo '
#!/bin/bash
docker-compose down
screen -S domjudge -X quit

' >domjudge/stop.sh
chmod +x domjudge/stop.sh

# Random password for judgehost
jdpw=$(openssl rand -hex 12)
sed -i "s/JUDGEDAEMON_PASSWORD=password/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml


sed -i "s/MYSQL_ROOT_PASSWORD=domjudge/MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_PASSWORD=domjudge/MYSQL_PASSWORD=$MYSQL_PASSWORD/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_USER=domjudge/MYSQL_USER=$MYSQL_USER/g" domjudge/docker-compose.yml
sed -i "s/MYSQL_DATABASE=domjudge/MYSQL_DATABASE=$MYSQL_DATABASE/g" domjudge/docker-compose.yml
sed -i "s/JUDGEDAEMON_PASSWORD=domjudge/JUDGEDAEMON_PASSWORD=$jdpw/g" domjudge/docker-compose.yml
echo "$jdpw" >domjudge/judgehost_password

echo "
Read and UNDERSTAND the instructions before doing anything

-- Steps to finish installation --
1. REBOOT THE SERVER. Do it! NOW!
2. Save the Judgehost password to a safe place, you will need it each time you want to add a new judgehost --> $jdpw
3. cd into the domjudge directory and execute ./start.sh. The first time will be slow, as it needs to create and configure everything.
4. As you will see in the logs, the judgehost container WILL FAIL. This is normal, as the credentials has not been added yet to the Domserver. Open a browser and login using the generated domjudge credentials, user admin, the password is in domjudge/initial_admin_password.secret.
5. Create a new user or modify a user in the web admin interface so the username is judgehost, the role is system judgehost and the password is $jdpw.
6. Change the admin password to something you will remember.
7. Stop the services executing ./stop.sh inside the domjudge folder.
8. Start the services executing ./start.sh inside the domjudge folder. Everything should start without errors.
9. Verify in the judgehosts section in the admin web interface that the judgehost has registered itself successfully.

-- Normal Operations --
Start services: start.sh
Stop services: stop.sh

-- Common Problems --
Problem 1: start.sh script fails or exits without doing anything --> Execute stop.sh, verify that screen -ls does not return any result, if there are any active domjudge screen kill them. (screen -r name followed by exit).
Problem 2: I do not know how to do X in DomJudge --> Login and access the docs section, everything should be documented.
Problem 3: Judgehost did not register itself / does not appear in the admin interface --> Double check that a user with username judgehost and the given password exists, and verify that the user has the system judgehost role.

-- I NEED HEEEEELP --
1. Try to google the problem first.
2. Open an issue in https://github.com/rmartinsanta/domjudge-automation/
" >Instructions.txt

echo "--> Doing a test run"
cd domjudge
docker-compose up --build --abort-on-container-exit

echo "--> Retrieving admin password file (initial_admin_password.secret)"
domserver=$(docker-compose ps -q domjudge)
docker cp $domserver:/opt/domjudge/domserver/etc/initial_admin_password.secret initial_admin_password.secret
error "Trying to get initial admin password from domserver ($domserver) container"
cd ..

echo "--> Cleaning up..."
sleep 1
chown -R $username:$username domjudge
error "Failed permission check"
echo "IMPORTANT: A new file called Instructions.txt has been created, follow the instructions carefully."
echo "INSTALLATION COMPLETED: you must reboot NOW."

