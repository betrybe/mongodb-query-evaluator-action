#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    printf "You must set envvar DBNAME\n"
    exit 1
fi
if [[ -z "$1" ]]; then
    printf "You must give an MQL as the first argument\n"
    exit 1
fi
# Replace single quotes (') by double quotes (") to avoid error on container exec bash command
mql=$(echo "$1" | sed -e "s/'/\"/g")

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi

# Exec MQL
cmd="mongo $DBNAME --quiet --eval 'DBQuery.shellBatchSize = 100000; DBQuery.prototype._prettyShell = true; JSON.stringify($mql); $mql'"
docker exec "$mongoContainerID" bash -c "$cmd"
