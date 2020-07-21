#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    echo "You must set envvar DBNAME"
    exit 1
fi

if [[ -z "$1"  ]]; then
    echo "You must give an path to MQL file as the first argument"
    exit 1
fi
mqlFile=$1


# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    echo "MongoDB container not found"
    exit 1
fi

# Exec MQL
cmd="mongo $DBNAME --quiet --eval 'DBQuery.shellBatchSize = 100000; $(cat $mqlFile)'"
docker exec "$mongoContainerID" bash -c "$cmd" || exit 1
