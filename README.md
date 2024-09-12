
# Domjudge Automation
This repo contains different utilities to simplify the deployment and administration of Domjudge instances.

## Recommended OS

We have installed and deployed Domjudge instances using the following Ubuntu versions:
- Ubuntu Server 18.04 LTS
- Ubuntu Server 20.04 LTS
- Ubuntu Server 22.04 LTS
- Ubuntu Server 24.04 LTS

Other distros may or may not work. 

## (Optional) Deploying an OpenStack instance
(Skip this section if you have your own virtual machine, or host, where you are going to install DomJudge)

Create your instance normally, but as a last step, inside the "Configuration" section, you need to fill the "Customization Script" with one of the following two alternatives.
![image](https://github.com/user-attachments/assets/9385408b-1910-49b9-9968-568e429f000f)

### Login with key (recommended)
```
#cloud-config
users:
  - default
  - name: domjudge
    ssh-authorized-keys:
      # This is my SSH Key, copied from 'https://github.com/rmartinsanta.keys'.
      # You must replace this key with your own!
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJe05YOIjubIzmfvapP5hVBG8cLxC0YEE2CoWK9wqRdxHYiuAm7qjHwK5QKvDmM8iRWHl9OTvD8t9Tvv2VMAdxdeaAkHvrpaCB9KNdU4raDcMRiV4couIK2jHX1ywmaeyO8DPh62k7q/ZJQTiD7e/B1glN2Y0256m44rn53FP5Ljr1KuwU4x7yp4wGAb43dAcKfWYzbfMBC9k3W7b2IXPbWiY2g8Dv3o4XNpOgEnHe3VrvAQj+wVgZ2U7HFFGEiayhz+v1a2zp3jt53Hg1BA6bxNz/onPS9gqotChnCFEXgiqS8MS60sEGGtZ1IEuIG2/WLTJ++vX9TrukfyBVGh7alUcBYwbGWHEyujYvVqSoND5AgH1kQTkAIpHpbN61JEqaNOMn1pK7V7vlsWSPzdUUQnYl87+rnzku3hzB0j4a75A/TA7oZuVDsXlNvNa/FMn8L7gekaYLkbe8zxK3bmyZWmm7wNvTGz/wimMmQ2mHc3+ZzpKsnufpVEm/OdLADKvhmlFH6IHLAGDVLFTR6yzTzw61xkJQXvHLNfbFGg6kr4k1Z+WZRclyA0Sfq+XahhJDma9IpfIXmD17i+9G3TDpcSyfWMvNv6daO3mijAxqCE/JRkOFoK/ny4mghsUc8Qpe+M2mhA5z6s0UDRHhfABeWUrJ4mOEYm0T9gawec0YqQ==
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
#Configure timezone
timezone: Europe/Madrid 
# Execute apt update && apt upgrade on first boot
package_update: true
package_upgrade: true
packages:
  - wget
  - fail2ban
  - git
  - unattended-upgrades
runcmd:
  - ["systemctl", "start", "fail2ban", "unattended-upgrades"]
  - ["systemctl", " enable", "fail2ban", "unattended-upgrades"] 
  - ["git", "clone", "https://github.com/rmartinsanta/domjudge-automation", "/home/domjudge/domjudge-automation"]
  - ["chown", "-R", "domjudge:domjudge", "/home/domjudge/domjudge-automation"]
```

The previous configuration allows the user to login only using a keypair. If for any reason you need to use passwords to authenticate via SSH see the following section.

### Login via password (NOT RECOMMENDED)
```
#cloud-config
ssh_pwauth: True
users:
  - default
  - name: domjudge
    lock_passwd: false
    chpasswd: { expire: False }
    # Generate a password hash using for example the following command: 'echo changethisurjcpassword | mkpasswd -m sha-512 -s'
    # Change 'changethisurjcpassword' with the password you want to actually use
    passwd: "$6$RJh/AweyyMOxuRGt$tqPMOhuG30JcAFoKypKH6h/B7E8Q/r3hE/dx2OvxrqjZDt7hZAYG/oDn4MrQyp0rIXh7.YsAnGTJ3Weex43gZ0"
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
# Execute apt update && apt upgrade on first boot
package_update: true
package_upgrade: true
packages:
  - wget
  - fail2ban
  - git
  - unattended-upgrades
runcmd:
  - ["systemctl", "start", "fail2ban", "unattended-upgrades"]
  - ["systemctl", " enable", "fail2ban", "unattended-upgrades"] 
  # Clone the repo and set owner to domjudge user
  - ["git", "clone", "https://github.com/rmartinsanta/domjudge-automation", "/home/domjudge/domjudge-automation"]
  - ["chown", "-R", "domjudge:domjudge", "/home/domjudge/domjudge-automation"]
```


## Domjudge installation

### Prerequisites
Install git and clone this repository to a folder of your choosing. Example:
```bash
sudo apt install git
git clone https://github.com/rmartinsanta/domjudge-automation/
cd domjudge-automation
```
Note that if you have deployed an OpenStack instance with the instructions from the previous section, git is already installed and the repository is cloned at `/home/domjudge/domjudge-automation`.

The installation process is completely automated and can be run using `sudo ./install-domjudge.sh`.

## Starting DomJudge

Run `./start.sh N`, where N is the number of judgehost to provision (must be < to the number of cores available).
The number of available judgehosts can be changed without stopping the services, just by executing `./start.sh` again.
For example, if we first execute DomJudge with `./start.sh 1`, and then we want to add 3 additional JudgeHost, we can just execute `./start.sh 4` and containers will scale accordingly. Reducing the number of judgehosts is also supported.

Note that it is normal if the first time DomJudge is started, no judgehosts appear inmediately. It can take up to 20 minutes for the Judgehosts to complete their setup and register themselves inside the DomJudge web interface. You may monitor their progress by using the `./viewlogs.sh` script.


## Stopping DomJudge and restarting

Run `./stop.sh` and wait until all containers are stopped. 

Tip: Remember that the number of judgehosts can be changed at any moment while the Judge is running to scale to any required workload, and calling `./stop.sh` is not required. If for example, the judge was deployed using `./start.sh 4`, and later the command `./start.sh 8` is run, 4 new judgehosts will created without touching the existing ones.

## Retrieving logs

Run: `./viewlogs.sh` to see what is happening inside the containers.

## Resetting DomJudge

The `./reset.sh` script will remove all stored data and prune Docker containers. After resetting the instance, you need to re-run the installation script.


## Customizing logos, team images, etc

Domjudge configure affiliations logos, team logos, countries, etc are stored under `/opt/domjudge/domserver/webapp/public/images`, inside the container, and the command `docker cp` can be used to copy any local file to the path inside the container. Example:

```bash
docker cp adabyron/images/. containername:/opt/domjudge/domserver/webapp/public/images/

```

## Monitoring stack
Optionally, a monitoring stack can be easily deployed to keep track of how the judge is performing:

* Change password inside `mon-template/monitoring/grafana/config/config.monitoring`
* Run `./start.sh` inside mon-template to start the monitoring stack
* Visit ip:1337 and login with admin and the password previously set.
* Stop monitoring stack with `./stop.sh` when no longer required.

# Have any problem?

Open an issue with at least the following info:
- OS version
- Installation logs if applicable
- Execution logs if applicable (use ./viewlogs.sh >logfile.txt to export them)
- Is the issue reproducible? What are the steps to reproduce the issue?
