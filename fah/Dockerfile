FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG DEB_FILE

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget

WORKDIR /root/Downloads

RUN wget $DEB_FILE

RUN apt-get -y install ./fah*.deb

WORKDIR /var/lib/fahclient

ENTRYPOINT [ "/usr/bin/FAHClient" ]
