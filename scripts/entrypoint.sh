#!/bin/sh -l

IMPORT_DIR=$1
CHALLENGES_DIR=$2

cd /
scripts/importdb.sh "/github/workspace/$IMPORT_DIR"
scripts/generate_result.sh "/github/workspace/$CHALLENGES_DIR" "/github/workspace/.challenges-expected"

if [ $? != 0 ]; then
  printf "Execution error"
  exit 1
fi

printf ::set-output name=result::`cat /tmp/trybe-results/evaluation_result.json | base64 -w 0`
printf ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
