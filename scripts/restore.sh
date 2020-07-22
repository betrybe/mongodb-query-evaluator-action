#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    printf "You must set envvar DBNAME"
    exit 1
fi
if [[ -z "$1" ]]; then
    printf "You must pass the BSON path as the first argument"
    exit 1
fi
BSON_PATH=$1

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi

# Restore collection
docker exec "$mongoContainerID" bash -c "mongorestore --db $DBNAME $BSON_PATH"
