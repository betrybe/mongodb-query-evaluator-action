FROM elixir:1.9-alpine

COPY scripts/ /
RUN ls -l

ENTRYPOINT ["/entrypoint.sh"]