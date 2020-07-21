FROM elixir:1.9-alpine

COPY scripts/ /

ENTRYPOINT ["/entrypoint.sh"]