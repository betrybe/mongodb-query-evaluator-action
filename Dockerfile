FROM alpine:3.12.0

RUN apk update && apk add docker

COPY scripts/ /scripts
RUN chmod a+x -R scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]