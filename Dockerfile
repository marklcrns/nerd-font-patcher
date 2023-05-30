FROM alpine:latest

LABEL org.opencontainers.image.title="Nerd Fonts Patcher" \
      org.opencontainers.image.description="Patches developer targeted fonts with a high number of glyphs (icons)." \
      org.opencontainers.image.source="https://github.com/marklcrns/nerd-font-patcher"

RUN apk update && apk upgrade && apk add --no-cache fontforge --repository=https://dl-cdn.alpinelinux.org/alpine/latest-stable/community && \
    apk add --no-cache py3-pip && \
    pip install configparser

ENV PYTHONIOENCODING=utf-8

VOLUME /in /out
COPY . /nerd

ENTRYPOINT [ "/bin/sh", "/nerd/docker-entrypoint.sh" ]
