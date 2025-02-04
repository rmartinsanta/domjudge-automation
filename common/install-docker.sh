#!/bin/bash
# DOMJudge installation script
# Author: Raul Martin <raul.martin@urjc.es>

set -e
echo "Docker installation script v1"

# Check privileges
if [[ $EUID -ne 0 ]]; then
   echo "The installation script must be run as root, change user or try with sudo" 
   exit 1
fi

# Helper function
error(){
    if [ $? -ne 0 ]; then
        echo "An error has ocurred in the following step: $1"
        exit 1
    fi
}

# Automatically restart services as required during apt install
export NEEDRESTART_MODE=a

# Try to enable cgroups memory
echo "--> Trying to enable cgroups ram support..."
if [ ! -z $(grep -P "GRUB_CMDLINE_LINUX=\x22\x22" "/etc/default/grub") ]; then 
   echo "--> Found default GRUB_CMDLINE in /etc/default/grub"
   echo "--> Enabling cgroup memory support"
   if [[ ! $(lsb_release -d) == *"2"[2-9]* ]]; then
       sed -i "s/GRUB_CMDLINE_LINUX=\x22\x22/GRUB_CMDLINE_LINUX=\x22cgroup_enable=memory swapaccount=1\x22/g" /etc/default/grub
   else
       sed -i "s/GRUB_CMDLINE_LINUX=\x22\x22/GRUB_CMDLINE_LINUX=\x22cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=false\x22/g" /etc/default/grub
   fi
   error "Trying to add cgroup_enable=memory swapaccount=1 to /etc/default/grub"
   echo "--> Updating GRUB..."
   update-grub
   error "Updating grub config"
elif [[ ! -z $(grep "cgroup_enable=memory swapaccount=1" "/etc/default/grub") ]]; then 
   echo "--> Detected cgroups memory support, skipping step"
else 
   echo "!!Error!! Non-standard GRUB_CMDLINE_LINUX parameter, please enable cgroups memory support"
   echo "Example: https://serverfault.com/questions/790318/cannot-enable-cgroup-enable-memory-swapaccount-1-on-gce-debian-jessie-instance"
   exit -1
fi

echo "--> Updating packages..."
apt update 
error "Update apt package list"
apt dist-upgrade -y
error "Upgrade apt packages"

echo "--> Installing dependencies..."
apt install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    open-vm-tools
error "Install docker depedencies"

echo "Installing /etc/apt/keyrings"
install -m 0755 -d /etc/apt/keyrings
error "Installing /etc/apt/keyrings"

echo "--> Downloading Docker signing key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
error "Add docker signing key"

echo "--> Adding Docker signing key..."
chmod a+r /etc/apt/keyrings/docker.asc
error "Add Docker signing key"

echo "--> Adding Docker repository..."
add-apt-repository -y \
   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
error "Add docker repository for current Linux"

echo "--> Installing Docker..."
apt update
error "Error running apt update after adding Docker repository, check that your Linux version is supported"
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
error "Error installing Docker, check that your Linux version is supported"

# Grant permission to use Docker to the current user

# Check if user domjudge exists
if id "domjudge" &>/dev/null; then
    echo "User domjudge exists. Granting Docker permission."
    usermod -aG docker domjudge
else
    # Retrieve the user that called the script using sudo
    if [ -n "$SUDO_USER" ]; then
        echo "User domjudge does not exist. Granting Docker permission to $SUDO_USER."
        usermod -aG docker "$SUDO_USER"
    else
        echo "Unable to determine a user to grant Docker permission. Skipping."
    fi
fi

# Check that everything is working
echo "--> Checking that docker is ready to use..."
docker run hello-world
error "Running example container"

echo "[OK] Docker installation finished"

