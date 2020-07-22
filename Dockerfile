FROM alpine:3.12.0

RUN apk update && apk add docker
RUN apk --update add git less openssh && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

COPY scripts/ /scripts
RUN chmod a+x -R scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]