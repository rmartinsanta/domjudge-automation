FROM domjudge/judgehost
RUN apt-get update && apt-get install -y netcat-traditional lsb-release wget
RUN wget -O /tmp/docker-cli.deb https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/docker-ce-cli_29.1.4-1~debian.12~bookworm_amd64.deb \
    && apt-get install -y /tmp/docker-cli.deb \
    && rm /tmp/docker-cli.deb
ADD waitfor.sh /scripts/waitfor.sh
ADD setenv.sh /scripts/setenv.sh
RUN chmod -R +x /scripts
CMD ["sh", "-c", "/scripts/waitfor.sh $DOMSERVER_HOST:80 -- /scripts/start.sh"]
