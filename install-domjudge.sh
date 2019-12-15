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

echo "--> Creating folders"
sleep 1
mkdir -p domjudge/domserver
mkdir -p domjudge/judgehost
error "Creating folders"

# Init pws
chmod +x changepasswords.sh
changepasswords.sh djdb dju >passwords.txt

echo "
-- Next steps --
1. REBOOT THE SERVER! Some configurations changes are not applied yet.
2. Start the database and the domserver with NO judgehosts --> ./start.sh 0
3. Get the default admin password for domjudge from the logs --> ./viewlogs.sh
4. Login in Domjudge and go to the Users section, edit the Judgehost user and set its password to the previously generated one. You can retrieve the passwords from the file passwords.txt, remove as soon as secured somewhere else.
5. Change the admin user password.
6. Launch as many judgehosts as you want with ./start N, but note that any judgehost that cannot be automatically assigned to a core will die, so make sure you have enough cores.
Judgehosts should register automatically and appear in the corresponding section.
7. Stop the services at any time executing ./stop.sh.

-- Any problem? --
1. Try to google the problem first.
2. Open an issue in https://github.com/rmartinsanta/domjudge-automation/
" >next_steps.txt
cat next_steps.txt

