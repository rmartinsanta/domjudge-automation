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

echo "--> Configuring database...."
read -p "Password for DB root user: " MYSQL_ROOT_PASSWORD
read -p "Database name for DomJudge: " MYSQL_DATABASE
read -p "Database user for DomJudge: " MYSQL_USER
read -p "Database password for DomJudge: " MYSQL_PASSWORD

echo "--> Creating folders"
sleep 1
mkdir domjudge
mkdir domjudge/database
mkdir domjudge/domserver
mkdir domjudge/judgehost
error "Creating folders"

# Init pws
chmod +x initpw.sh
initpw.sh 

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

