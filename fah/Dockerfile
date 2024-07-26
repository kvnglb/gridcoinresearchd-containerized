FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG DEB_FILE

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget
RUN adduser --system --no-create-home --group fah-client

WORKDIR /root/Downloads

RUN wget $DEB_FILE

RUN apt-get -y install ./fah*.deb

WORKDIR /var/lib/fah-client

ENTRYPOINT [ "/usr/bin/fah-client" ]
