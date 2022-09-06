FROM domjudge/judgehost
RUN apt-get update && apt-get install -y netcat docker.io
ADD waitfor.sh /scripts/waitfor.sh
ADD setenv.sh /scripts/setenv.sh
ADD start.sh /scripts/start.sh
RUN chmod -R +x /scripts
CMD ["sh", "-c", "/scripts/waitfor.sh $DOMSERVER_HOST:80 -- /scripts/start.sh"]
