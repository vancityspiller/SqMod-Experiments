# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------

FROM        debian:10-slim

LABEL       author="Spiller" maintainer="spiller@vcmp.net"

RUN         apt-get update
RUN         apt-get install -y git build-essential cmake default-libmysqlclient-dev libpq-dev zlib1g-dev libssl-dev libcurl4-openssl-dev libsodium-dev gnutls-dev automake autoconf libtool pkg-config
RUN         adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]