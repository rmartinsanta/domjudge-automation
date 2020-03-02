# Domjudge Automation

## Domjudge installation
Run ./install-domjudge.sh and follow the provided steps in the script.

## Domjudge start services
Run './start.sh 0' the first time, and change the judgehost user password.
Run './start.sh N', where N is the number of judgehost to provision (must be < to the number of cores available).
 
## Domjudge stop services
Run './stop.sh'

## Monitoring stack

* Change password inside mon-template/monitoring/grafana/config/config.monitoring
* Run ./start.sh inside mon-template to start the monitoring stack
* Visit ip:1337 and login with admin and the password previously set.
* Stop monitoring stack with ./stop.sh
