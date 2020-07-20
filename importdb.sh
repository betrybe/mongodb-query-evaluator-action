#!/bin/bash

if [[ -z "$DBNAME" ]]; then
    echo "You must set envvar DBNAME"
    exit 1
fi

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    echo "MongoDB container not found"
    exit 1
fi

# Reset DB
docker exec "$mongoContainerID" bash -c "mongo $DBNAME --eval 'db.dropDatabase()'"

# Restore aggregation
for entry in assets/*.bson
do
    collection=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/assets\///g")
    docker exec "$mongoContainerID" bash -c "mongorestore --db $DBNAME /project/assets/$collection.bson"
done