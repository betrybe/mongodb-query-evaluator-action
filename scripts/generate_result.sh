#!/bin/sh -l

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1

RESULTS_DIR="/tmp/trybe-results"
mkdir "$RESULTS_DIR"

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi
# Create result collection with project data
docker exec "$mongoContainerID" bash -c "mongo $DBNAME --eval 'db.createCollection(\"trybe_evaluation\")'"
doc='{"github_username": "'"$GITHUB_ACTOR"'","github_repository_name": "'"$GITHUB_REPOSITORY"'","evaluations": []}'
docker exec "$mongoContainerID" bash -c "mongo $DBNAME --eval 'db.inventory.insertOne($doc)'"

identifier='{"github_username": "'"$GITHUB_ACTOR"'"}'
FAILED=0
for entry in "/github/workspace/$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  challengeName=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/\/github\/workspace\/$CHALLENGES_DIR\///g")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$challengeName"
  touch "$resultPath"
  # Exec query into mongo container
  mql=$(cat "$entry")
  /scripts/exec.sh "$mql" &> "$resultPath"
  # Check result with the expected and update result collection
  diff=$(diff "$resultPath" /github/workspace/.challenges-expected/"$challengeName")
  if [[ ! -z "$diff" ]]; then
    update='{"$push": {"description": "'"$challengeName"'","grade": 1}}'
    /scripts/exec.sh "db.inventory.update($identifier, $update)"
    FAILED=1
    continue
  fi

  update='{"$push": {"description": "'"$challengeName"'","grade": 3}}'
  /scripts/exec.sh "db.inventory.update($identifier, $update)"
done

exit $FAILED
