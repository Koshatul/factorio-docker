FROM alpine:3.6

LABEL maintainer="koshatul@gmail.com" \
  au.com.czero.vendor="Control Zero" \
  au.com.czero.project="Factorio Server" \
  description="Factorio Server Docker Container"

ENV GLIBC_VERSION 2.25-r0

## Glibc fix from https://github.com/jeanblanchard/docker-alpine-glibc
RUN apk add --update curl xz \
  && curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
  && curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" \
  && curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" \
  && apk add glibc-bin.apk glibc.apk\
  && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
  && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf \
  && rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

RUN mkdir -p /factorio /saves /config \
  && adduser -D -s /bin/bash -g "" factorio \
  && chown -R factorio: /factorio /saves /config

USER factorio
WORKDIR /factorio
VOLUME ["/saves", "/config"]

ENV SAVE /saves/server.zip
ENV HOME /factorio
ENV VERSION 0.15.0

RUN curl -s https://www.factorio.com/download-headless/experimental | grep -o "/get-download/.*/headless/linux64" | grep "${VERSION}" | awk '{print "-L -s -o /tmp/factorio.tar.gz https://www.factorio.com"$1}' | xargs curl \
  && tar xf /tmp/factorio.tar.gz --strip-components=1 -C /factorio \
  && rm -f /tmp/factorio.tar.gz

COPY init.sh /init.sh

EXPOSE 34197/udp

ENTRYPOINT ["/init.sh"]
