#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    printf "You must set envvar DBNAME"
    exit 1
fi
if [[ -z "$1"  ]]; then
    printf "You must give an MQL as the first argument"
    exit 1
fi
mql=$1

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi

# Exec MQL
cmd="mongo $DBNAME --quiet --eval 'DBQuery.shellBatchSize = 100000; $mql'"
docker exec "$mongoContainerID" bash -c "$cmd" || exit 1
