#!/bin/sh -l
set -x

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1
if [[ -z "$2" ]]; then
    printf "You must pass the Mongo container workdir as the second argument"
    exit 1
fi
MONGO_WORKDIR=$2

RESULTS_DIR="/tmp/trybe-results"
mkdir "$RESULTS_DIR"

FAILED=0
for entry in "/github/workspace/$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  challengeName=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/\/github\/workspace\/$CHALLENGES_DIR\///g")
  echo "======> $challengeName"
  # Build path to results dir
  resultPath="$RESULTS_DIR/$challengeName"
  touch "$resultPath"
  # Exec query into mongo container
  /scripts/exec.sh "/$MONGO_WORKDIR/$CHALLENGES_DIR/$challengeName.js" &> "$resultPath"
  # Check result with the expected
  cat "/github/workspace/.challenges-expected/$challengeName"
  echo "======> RESULT"
  cat "$resultPath"
  if [[ ! -z $(diff "$resultPath" /github/workspace/.challenges-expected/"$challengeName") ]]; then
    printf "$challengeName failed"
    FAILED=1
    continue
  fi

  printf "$challengeName passed"
done

exit $FAILED
