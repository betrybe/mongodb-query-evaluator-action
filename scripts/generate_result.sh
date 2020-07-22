#!/bin/sh -l

if [[ -z "$1" ]]; then
    printf "You must pass the challenges dir as the first argument"
    exit 1
fi
CHALLENGES_DIR=$1

RESULTS_DIR="/tmp/trybe-results"
mkdir "$RESULTS_DIR"

FAILED=0
for entry in "/github/workspace/$CHALLENGES_DIR"/*.js
do
  # Get challenge name
  challengeName=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/\/github\/workspace\/$CHALLENGES_DIR\///g")
  # Build path to results dir
  resultPath="$RESULTS_DIR/$challengeName"
  touch "$resultPath"
  # Exec query into mongo container
  /scripts/exec.sh "$entry" &> "$resultPath"
  # Check result with the expected
  diff=$(diff "$resultPath" /github/workspace/.challenges-expected/"$challengeName")
  if [[ ! -z "$diff" ]]; then
    printf "$challengeName failed"
    FAILED=1
    continue
  fi

  printf "$challengeName passed"
done

exit $FAILED
