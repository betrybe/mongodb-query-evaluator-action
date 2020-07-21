#!/bin/sh -l
set -x

if [[ -z "$1" ]]; then
    echo "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1
if [[ -z "$2" ]]; then
    echo "You must pass the Mongo container workdir as the second argument"
    exit 1
fi
MONGO_WORKDIR=$2

for entry in "/github/workspace/$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  challengeName=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/\/github\/workspace\/$CHALLENGES_DIR\///g")
  # Build path to results dir
  resultFile="/$MONGO_WORKDIR/$CHALLENGES_DIR/results/$challengeName"
  # Exec query into mongo container
  ./scripts/exec.sh "/$MONGO_WORKDIR/$CHALLENGES_DIR/$challengeName.js" &> "$resultFile"
  # Check result with the expected
  if [[ ! -z $(diff "$resultFile" "/github/workspace/.challenges-expected/$challengeName") ]]; then
    echo "$challengeName failed"
    continue
  fi

  echo "$challengeName passed"
done