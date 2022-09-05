
# Domjudge Automation

## Recommended OS

We have installed and deployed Domjudge instances using Ubuntu 18.04 LTS, Ubuntu 20.04 LTS and Ubuntu 22.04 LTS. Other distros may or may not work. 

## Domjudge installation

Run ./install-domjudge.sh and follow the provided steps in the script.

## Starting services

First time, run './start.sh 0', login into the domjudge admin panel and change the judgehost user password to the provided value in the password file.

Run './start.sh N', where N is the number of judgehost to provision (must be < to the number of cores available).

Tip: The number of judgehosts can be changed at any moment while the Judge is running to scale to any required workload. If for example, the judge was deployed using './start.sh 4', and later the command './start.sh 8' is run, 4 new judgehosts will created without touching the existing ones.

## Stop services and restarting

Run './stop.sh' and wait until all containers are stopped. 

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
- Execution logs if applicable (use ./viewlogs.sh)
- Is the issue reproducible? With what steps?
