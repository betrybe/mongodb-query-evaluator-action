#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    echo "You must set envvar DBNAME"
    exit 1
fi
if [[ -z "$1" ]]; then
    echo "You must pass the import dir as the first argument"
    exit 1
fi
IMPORT_DIR=$1

docker ps
# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    echo "MongoDB container not found"
    exit 1
fi

# Reset DB
docker exec "$mongoContainerID" bash -c "mongo $DBNAME --eval 'db.dropDatabase()'"

# Restore aggregation
for entry in "/github/workspace/$IMPORT_DIR"/*.bson
do
    collection=$(echo "$entry" | sed -e "s/.bson//g" | sed -e "s/\/github\/workspace\/$IMPORT_DIR\///g")
    docker exec "$mongoContainerID" bash -c "mongorestore --db $DBNAME /github/workspace/$IMPORT_DIR/$collection.bson"
done