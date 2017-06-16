FROM ubuntu:xenial

LABEL maintainer="koshatul@gmail.com" \
  au.com.czero.vendor="Control Zero" \
  au.com.czero.project="Factorio Server" \
  version="experimental" \
  description="Factorio Server Docker Container"

RUN apt update \
  && apt dist-upgrade -y \
  && apt install -y curl xz-utils \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /factorio /saves /config \
  && adduser --disabled-login --shell /bin/bash --gecos "" factorio \
  && chown -R factorio: /factorio /saves /config

USER factorio

WORKDIR /factorio
VOLUME ["/saves", "/config"]

ENV SAVE /saves/server.zip
ENV HOME /factorio
ENV VERSION 0.15.20

RUN curl -s https://www.factorio.com/download-headless/experimental | grep -o "/get-download/.*/headless/linux64" | grep "${VERSION}" | awk '{print "-L -s -o /tmp/factorio.tar.gz https://www.factorio.com"$1}' | xargs curl \
  && tar xf /tmp/factorio.tar.gz --strip-components=1 -C /factorio \
  && rm -f /tmp/factorio.tar.gz

COPY init.sh /init.sh

EXPOSE 34197/udp

ENTRYPOINT ["/init.sh"]
