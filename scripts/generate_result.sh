#!/bin/sh -l
set -x

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
if [[ -z "$3" ]]; then
    printf "You must pass the Trybe DB restore dir as the third argument"
    exit 1
fi
DB_RESTORE_DIR=$3

RESULTS_DIR="/tmp/trybe-results"
mkdir "$RESULTS_DIR"

# Create result collection with project data
scripts/exec.sh 'db.createCollection("trybe_evaluation")'
doc='{"github_username": "'"$GITHUB_ACTOR"'","github_repository_name": "'"$GITHUB_REPOSITORY"'","evaluations": []}'
scripts/exec.sh "db.trybe_evaluation.insertOne($doc)"

docIdentifier='{"github_username": "'"$GITHUB_ACTOR"'"}'
for entry in "$TRYBE_DIR/expected-results"/*
do
  scripts/resetdb.sh "$DB_RESTORE_DIR"
  # Get challenge name and desc
  chName=$(echo "$(basename $entry)")
  chDesc=$(cat "$TRYBE_DIR"/requirements.json | jq -r ".requirements[] | select (.identifier==\"desafio2\") | .description")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$chName"
  touch "$resultPath"
  # Check if challenge MQL file exists
  mqlFile="$CHALLENGES_DIR/$chName".js
  if [ ! -f $mqlFile ]; then
    update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": 1}}}'
    scripts/exec.sh "db.trybe_evaluation.update($docIdentifier, $update)"
    continue
  fi
  # Exec query into mongo container
  mql=$(cat "$mqlFile")
  scripts/exec.sh "$mql" &> "$resultPath"
  # Check result with the expected and build doc to add into result collection
  diff=$(diff "$resultPath" "$TRYBE_DIR/expected-results/$chName")
  if [[ ! -z "$diff" ]]; then
    update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": 1}}}'
    scripts/exec.sh "db.trybe_evaluation.update($docIdentifier, $update)"
    continue
  fi

  update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": 3}}}'
  scripts/exec.sh "db.trybe_evaluation.update($docIdentifier, $update)"
done

scripts/exec.sh "db.trybe_evaluation.findOne($docIdentifier)" > "$RESULTS_DIR/evaluation_result.json"
echo "====== RESULTS ======"
cat "$RESULTS_DIR/evaluation_result.json"
