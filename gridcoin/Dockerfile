FROM debian:trixie

ARG DEBIAN_FRONTEND=noninteractive
ARG DEB_FILE
ARG DEB_FILE_SHA256

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget

WORKDIR /root/Downloads

RUN wget $DEB_FILE

RUN if [ "$(sha256sum gridcoinresearchd*.deb | cut -d ' ' -f1)" = $DEB_FILE_SHA256 ]; then \
      exit 0; \
    else \
      echo "Checksum does not match"; exit 1; \
    fi

RUN apt-get -y install ./gridcoinresearchd*.deb

WORKDIR /root/.GridcoinResearch

ENTRYPOINT [ "/usr/bin/gridcoinresearchd" ]
