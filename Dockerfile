FROM debian:latest
#
#
#
MAINTAINER "Gerónimo Afonso" <geronimo.afonso@mikroways.net>

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && touch /root/.Xauthority \
  && true

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory, but also be able to sudo
RUN useradd docker \
        && passwd -d docker \
        && mkdir /home/docker \
        && chown docker:docker /home/docker \
        && addgroup docker staff \
        && addgroup docker sudo \
        && true
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > etc/apt/sources.list.d/pgdg.list
RUN apt-get update && \
	apt-get install --no-install-recommends -qy \
	wget \
	mysql-client \
	rsync \
	vim
RUN apt-get install -y ca-certificates && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && \
	apt-get install --no-install-recommends -qy postgresql-client-9.5 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

EXPOSE 22
CMD ["/run.sh"]
