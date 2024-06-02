FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive
ARG DEB_FILE
ARG DEB_FILE_HASH

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install wget

WORKDIR /root/Downloads

RUN wget $DEB_FILE
RUN wget $DEB_FILE_HASH

RUN if [ "$(sha256sum gridcoinresearchd*.deb | cut -d ' ' -f1)" = "$(cat *.SHA256 | cut -d ' ' -f 1)" ]; then \
      exit 0; \
    else \
      echo "Checksum does not match"; exit 1; \
    fi

RUN apt-get -y install ./gridcoinresearchd*.deb

WORKDIR /root/.GridcoinResearch

ENTRYPOINT [ "/usr/bin/gridcoinresearchd" ]
