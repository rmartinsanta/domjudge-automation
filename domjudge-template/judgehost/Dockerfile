FROM domjudge/judgehost
RUN apt-get update && apt-get install -y netcat docker.io
ADD waitfor.sh /scripts/waitfor.sh
RUN chmod +x /scripts/waitfor.sh
ADD setenv.sh /scripts/setenv.sh
RUN chmod +x /scripts/setenv.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $DOMSERVER_HOST:80 -- /scripts/start.sh"]