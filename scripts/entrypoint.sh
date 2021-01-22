#!/bin/sh -l

cd /
scripts/generate_result.sh "/github/workspace/$INPUT_CHALLENGES_DIR" "/github/workspace/.trybe" "/github/workspace/$INPUT_DB_RESTORE_DIR"

if [ $? != 0 ]; then
  printf "Execution error $?"
  exit 1
fi

echo ::set-output name=result::`cat /tmp/trybe-results/evaluation_result.json | base64 -w 0`
echo ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
