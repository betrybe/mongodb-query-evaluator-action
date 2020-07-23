#!/bin/sh -l

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1
if [[ -z "$2" ]]; then
    printf "You must pass the Trybe dir as the second argument"
    exit 1
fi
TRYBE_DIR=$2

ls -l "$TRYBE_DIR"

RESULTS_DIR="/tmp/trybe-results"
mkdir "$RESULTS_DIR"

# Get MongoDB Container ID
mongoContainerID=$(docker ps --format "{{.ID}} {{.Names}}" | grep mongo | cut -d ' ' -f1)
if [[ -z "$mongoContainerID" ]]; then
    printf "MongoDB container not found"
    exit 1
fi
# Create result collection with project data
scripts/exec.sh 'db.createCollection("trybe_evaluation")'
doc='{"github_username": "'"$GITHUB_ACTOR"'","github_repository_name": "'"$GITHUB_REPOSITORY"'","evaluations": []}'
scripts/exec.sh "db.trybe_evaluation.insertOne($doc)"

collIdentifier='{"github_username": "'"$GITHUB_ACTOR"'"}'
for entry in "$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  chName=$(echo "$(basename $entry)" | sed -e "s/.js//g")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$chName"
  touch "$resultPath"
  # Exec query into mongo container
  mql=$(cat "$entry")
  scripts/exec.sh "$mql" &> "$resultPath"
  # Check result with the expected and build doc to add into result collection
  chDesc=$(cat requirements.json | jq -r ".requirements[] | select (.identifier==\"desafio2\") | .description")
  diff=$(diff "$resultPath" "$TRYBE_DIR/expected-results/$chName")
  if [[ ! -z "$diff" ]]; then
    update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": 1}}}'
    scripts/exec.sh "db.trybe_evaluation.update($collIdentifier, $update)"
    continue
  fi

  update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": 3}}}'
  scripts/exec.sh "db.trybe_evaluation.update($collIdentifier, $update)"
done

scripts/exec.sh "db.trybe_evaluation.find()" > "$RESULTS_DIR/evaluation_result.json"
