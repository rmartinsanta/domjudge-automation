FROM domjudge/domserver
RUN apt-get update && apt-get install -y netcat
AD waitfor.sh /scripts/waitfor.sh
RUN chmod +x /scripts/waitfor.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $MYSQL_HOST:3306 -- /scripts/start.sh"]
