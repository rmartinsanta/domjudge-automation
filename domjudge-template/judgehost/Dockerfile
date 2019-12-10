FROM domjudge/judgehost
RUN apt-get update && apt-get install -y netcat
ADD waitfor.sh /scripts/waitfor.sh
RUN chmod +x /scripts/waitfor.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $DOMSERVER_HOST:80 -- /scripts/start.sh"]