#!/bin/sh -l

CORRECT_GRADE=3
INCORRECT_GRADE=1

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument\n"
    exit 1
fi
CHALLENGES_DIR=$1
if [[ -z "$2" ]]; then
    printf "You must pass the Trybe dir as the second argument\n"
    exit 1
fi
TRYBE_DIR=$2
if [[ -z "$3" ]]; then
    printf "You must pass the Trybe DB restore dir as the third argument\n"
    exit 1
fi
DB_RESTORE_DIR=$3

RESULTS_DIR="/tmp/trybe-results"
rm -rf "$RESULTS_DIR"
mkdir "$RESULTS_DIR"

# Create result collection with project data
DBNAME=trybe scripts/exec.sh "db.dropDatabase()"
DBNAME=trybe scripts/exec.sh 'db.createCollection("evaluation")'
doc='{"github_username": "'"$INPUT_PR_AUTHOR_USERNAME"'","github_repository_name": "'"$GITHUB_REPOSITORY"'","evaluations": []}'
DBNAME=trybe scripts/exec.sh "db.evaluation.insertOne($doc)"
docIdentifier='{"github_username": "'"$INPUT_PR_AUTHOR_USERNAME"'"}'

# Add challenge result to evaluation collection
updateEvaluation() {
  chName=$1
  chDesc=$2
  grade=$3
  update='{"$addToSet": {"evaluations": {"identifier": "'"$chName"'","description": "'"$chDesc"'","grade": '$grade' }}}'
  DBNAME=trybe scripts/exec.sh "db.evaluation.update($docIdentifier, $update)"
}

# Check each expected challenge result with the MQL sent on PR in the challenges folder
for entry in "$TRYBE_DIR/expected-results"/*
do
  scripts/resetdb.sh "$DB_RESTORE_DIR"
  # Get challenge name and desc
  chName=$(echo "$(basename $entry)")
  chDesc=$(cat "$TRYBE_DIR"/requirements.json | jq -r ".requirements[] | select (.identifier==\"$chName\") | .description")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$chName"
  touch "$resultPath"
  # Check if challenge MQL file exists
  mqlFile="$CHALLENGES_DIR/$chName".js
  if [ ! -f $mqlFile ]; then
    updateEvaluation "$chName" "$chDesc" $INCORRECT_GRADE
    continue
  fi
  # Exec query into mongo container and sort result
  mql=$(cat "$mqlFile" | sed -r "s/;+$//")
  scripts/exec.sh "$mql" | jq -S &> "$resultPath"
  # Sort expected result
  cat "$TRYBE_DIR/expected-results/$chName" | jq -S > "/tmp/expected_sorted"
  # Check result with the expected and build doc to add into result collection
  diff=$(diff "$resultPath" "/tmp/expected_sorted" --ignore-all-space)
  if [[ ! -z "$diff" ]]; then
    updateEvaluation "$chName" "$chDesc" $INCORRECT_GRADE
    continue
  fi

  updateEvaluation "$chName" "$chDesc" $CORRECT_GRADE
done

DBNAME=trybe scripts/exec.sh "db.evaluation.findOne($docIdentifier, {_id: 0})" > "$RESULTS_DIR/evaluation_result.json"
printf "======================== RESULTS ========================\n"
cat "$RESULTS_DIR/evaluation_result.json"
