FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.6.0rc3

RUN yum install -y epel-release
RUN yum install -y https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm && \
    yum clean all

VOLUME ["/etc/kong/"]

COPY config.docker/kong.yml /etc/kong/kong.yml

# Set the cluster "advertise" property either by a set environment variable, or by auto-detecting the IP address of the container
RUN if [ -z "$ADVERTISE" ]; then \
  hostname=`hostname` && ADVERTISE=`awk '/^[[:space:]]*($|#)/{next} /'$hostname'/{print $1; exit}' /etc/hosts` && ip=$ip":7946"; \
fi; \
echo -e 'cluster:\n  advertise: "'$ADVERTISE'"' >> /etc/kong/kong.yml;

CMD kong start && tail -f /usr/local/kong/logs/error.log

EXPOSE 8000 8443 8001 7946
