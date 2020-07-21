#!/bin/sh -l

if [[ -z "$DBNAME" ]]; then
    printf "You must set envvar DBNAME"
    exit 1
fi
if [[ -z "$1" ]]; then
    printf "You must pass the import dir as the first argument"
    exit 1
fi
IMPORT_DIR=$1
if [[ -z "$2" ]]; then
    printf "You must pass the Mongo container workdir as the second argument"
    exit 1
fi
MONGO_WORKDIR=$2

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi

# Reset DB
docker exec "$mongoContainerID" bash -c "mongo $DBNAME --eval 'db.dropDatabase()'"

# Extract BSON's
for entry in /github/workspace/"$IMPORT_DIR"/*.tar.gz
do
    tar -xvf "$entry" -C "/github/workspace/$IMPORT_DIR"
done

# Restore aggregations
for entry in /github/workspace/"$IMPORT_DIR"/*.bson
do
    collection=$(printf '%s' "$entry" | sed -e "s/.bson//g" | sed -e "s/\/github\/workspace\/$IMPORT_DIR\///g")
    docker exec "$mongoContainerID" bash -c "mongorestore --db $DBNAME /$MONGO_WORKDIR/$IMPORT_DIR/$collection.bson"
done