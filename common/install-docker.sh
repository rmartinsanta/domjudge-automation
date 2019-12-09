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


# Try to enable cgroups memory
echo "--> Trying to enable cgroups ram support..."
if [ ! -z $(grep -P "GRUB_CMDLINE_LINUX=\x22\x22" "/etc/default/grub") ]; then 
   echo "--> Found default GRUB_CMDLINE in /etc/default/grub"
   echo "--> Enabling cgroup memory support"
   sed -i "s/GRUB_CMDLINE_LINUX=\x22\x22/GRUB_CMDLINE_LINUX=\x22cgroup_enable=memory swapaccount=1\x22/g" /etc/default/grub
   error "Trying to add cgroup_enable=memory swapaccount=1 to /etc/default/grub"
   echo "--> Updating GRUB..."
   update-grub
   error "Updating grub config"
elif [ ! -z $(grep "cgroup_enable=memory swapaccount=1" "/etc/default/grub") ]; then 
   echo "--> Detected cgroups memory support, skipping step"
else 
   echo "!!Error!! Non-standard GRUB_CMDLINE_LINUX parameter, please enable cgroups memory support"
   echo "Example: https://serverfault.com/questions/790318/cannot-enable-cgroup-enable-memory-swapaccount-1-on-gce-debian-jessie-instance"
   exit -1
fi


# Update package index
echo "--> Updating package index and installing dependencies..."
sleep 1
apt update
error "Update apt package list"

# Update system
echo "--> Updating package index and installing dependencies..."
sleep 1
apt dist-upgrade -y
error "Upgrade system using apt"

# Install docker dependencies
apt install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
error "Install docker depedencies"

# Add Docker signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
error "Add docker signing key"

# Add Docker repo
echo "--> Adding Docker repository..."
sleep 1
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
error "Add docker repository for current Linux"

# Install docker
echo "--> Installing Docker..."
sleep 1
apt update
apt install -y docker-ce docker-ce-cli containerd.io
error "Installing Docker, check that your Linux version is supported"

# Download and install Docker Compose
echo "--> Downloading docker compose..."
curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
error "Downloading Docker Compose"
chmod +x /usr/bin/docker-compose
error "Installing Docker Compose"

# Grant permission to use Docker to the given user
user=$(whoami)
echo "--> Granting Docker privileges to user $user..."
#echo "Write the username that will be granted permission to use Docker and DOMJudge."
#echo "You may use the current user, or create a new user with 'adduser' in a different terminal before proceeding"
#read -p "Username: " username
usermod -aG docker $user
error "Granting privileges to use Docker to $user"

# Check that everything is working
echo "--> Checking that docker and docker-compose are available and ready to use..."
docker version
error "Checking Docker version"
docker-compose -version
error "Checking Docker Compose version"
