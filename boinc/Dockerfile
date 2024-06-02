FROM almalinux:9

RUN dnf -y --refresh update
RUN dnf -y install epel-release
RUN dnf -y install boinc-client

WORKDIR /var/lib/boinc

ENTRYPOINT [ "/usr/bin/boinc", "--dir", "/var/lib/boinc" ]
