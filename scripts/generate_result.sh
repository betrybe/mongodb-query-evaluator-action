#!/bin/sh -l

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1
if [[ -z "$2" ]]; then
    printf "You must pass the expected dir as the second argument"
    exit 1
fi
EXPECTED_DIR=$2

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

identifier='{"github_username": "'"$GITHUB_ACTOR"'"}'
FAILED=0
for entry in "$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  challengeName=$(echo "$(basename $entry)" | sed -e "s/.js//g")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$challengeName"
  touch "$resultPath"
  # Exec query into mongo container
  mql=$(cat "$entry")
  scripts/exec.sh "$mql" &> "$resultPath"
  # Check result with the expected and update result collection
  diff=$(diff "$resultPath" "$EXPECTED_DIR/$challengeName")
  if [[ ! -z "$diff" ]]; then
    update='{"$addToSet": {"evaluations": {"identifier": "'"$challengeName"'","grade": 1}}}'
    scripts/exec.sh "db.trybe_evaluation.update($identifier, $update)" || exit 1
    FAILED=1
    continue
  fi

  update='{"$addToSet": {"evaluations": {"identifier": "'"$challengeName"'","grade": 3}}}'
  scripts/exec.sh "db.trybe_evaluation.update($identifier, $update)" || exit 1
done

scripts/exec.sh "db.trybe_evaluation.find()" > "$RESULTS_DIR/evaluation_result.json"

exit $FAILED
