
# Domjudge Automation
This repo contains different utilities to simplify the deployment and administration of Domjudge instances.

## Recommended OS

We have installed and deployed Domjudge instances using the following Ubuntu versions:
- Ubuntu Server 18.04 LTS
- Ubuntu Server 20.04 LTS
- Ubuntu Server 22.04 LTS
- Ubuntu Server 24.04 LTS

Other distros may or may not work. 

## Domjudge installation

Run ./install-domjudge.sh and follow the provided steps in the script.

## Starting services

Run './start.sh N', where N is the number of judgehost to provision (must be < to the number of cores available).
The number of available judgehosts can be changed without stopping the services, just by executing ./start.sh again.
For example, if we first execute DomJudge with './start.sh 1', and then we want to add 3 additional JudgeHost, we can just execute './start.sh 4' and containers will scale accordingly. Reducing the number of judgehosts is also supported.


## Stop services and restarting

Run './stop.sh' and wait until all containers are stopped. 

Tip: Remember that the number of judgehosts can be changed at any moment while the Judge is running to scale to any required workload, and calling './stop.sh' is not required. If for example, the judge was deployed using './start.sh 4', and later the command './start.sh 8' is run, 4 new judgehosts will created without touching the existing ones.

## Customizing logos, team images, etc

Domjudge configure affiliations logos, team logos, countries, etc are stored under /opt/domjudge/domserver/webapp/public/images, inside the container, and the command docker cp can be used to copy any local file to the path inside the container. Example:

```bash
docker cp adabyron/images/. containername:/opt/domjudge/domserver/webapp/public/images/

```

## Monitoring stack
Optionally, a monitoring stack can be easily deployed to keep track of how the judge is performing:

* Change password inside mon-template/monitoring/grafana/config/config.monitoring
* Run ./start.sh inside mon-template to start the monitoring stack
* Visit ip:1337 and login with admin and the password previously set.
* Stop monitoring stack with ./stop.sh when no longer required.

# Have any problem?

Open an issue with at least the following info:
- OS version
- Installation logs if applicable
- Execution logs if applicable (use ./viewlogs.sh >logfile.txt to export them)
- Is the issue reproducible? What are the steps to reproduce the issue?
