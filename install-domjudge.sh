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

# Create storage dirs
echo "--> Creating folders"
mkdir -p /storage/docker/mysql
error "Creating /storage/docker/mysql"
mkdir -p domjudge/domserver
error "Creating domjudge/domserver"
mkdir -p domjudge/judgehost
error "Creating domjudge/judgehost"

# Initialize passwords
chmod +x changepasswords.sh
./changepasswords.sh djdb dju >passwords.txt

# Download current version of containers and try to extract domjudge admin password
cd domjudge
docker compose pull
docker compose up --scale jh=0 |
  tee /dev/tty | {
    grep -q "php entered RUNNING state"
    adminpw=$(docker compose logs | grep -oP 'Initial admin password is\s*\K.*')
    jhpw=$(docker compose logs | grep -oP 'Initial judgehost password is\s*\K.*')
    
    { cat <<EOF
#########################
#   INITIAL PASSWORDS   #
#########################

- Admin user: admin
- Admin password: $adminpw
- Judgehost user: judgehost
- Judgehost password: $jhpw

#########################
# END INITIAL PASSWORDS #
#########################
EOF
   } | tee passwords.txt
   sed -i "s/JUDGEDAEMON_PASSWORD=password/JUDGEDAEMON_PASSWORD=$jhpw/g" docker-compose.yml
    docker compose down
    cat >/dev/null
  }


echo "
-- Next steps --
1. REBOOT THE SERVER! Some changes need a reboot to be applied.
2. Retrieve your passwords from passwords.txt, store them somewhere safe and shred the file. 
3. Launch DomJudge with N judgehosts with './start.sh N'. Note that N can be arbitrarily large, but any judgehost that cannot be assigned to a CPU core will die, so make sure you have enough cores.
Judgehosts should register automatically and appear in the corresponding section inside the DomJudge interface
4. Stop the services at any time executing ./stop.sh.

-- Any problem? --
1. Try to google the problem first.
2. Open an issue in https://github.com/rmartinsanta/domjudge-automation/
When reporting issues, please attach the output of 'docker ps' and './viewlogs.sh'.
" >next_steps.txt
cat next_steps.txt

