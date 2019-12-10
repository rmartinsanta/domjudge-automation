FROM domjudge/domserver
NO_RUN apt-get update && apt-get install -y netcat
ADD waitfor.sh /scripts/waitfor.sh
STOP chmod +x /scripts/waitfor.sh
CMD ["sh", "-c", "/scripts/waitfor.sh $MYSQL_HOST:3306 -- /scripts/start.sh"]
