#!/bin/sh -l

DB_RESTORE_DIR=$1
CHALLENGES_DIR=$2

git clone https://github.com/$GITHUB_REPOSITORY.git --single-branch /github/master-repo/

if [ $? != 0 ]; then
  printf "Execution error $?"
  exit 1
fi

cd /
scripts/generate_result.sh "/github/workspace/$CHALLENGES_DIR" "/github/master-repo/.trybe" "/github/workspace/$DB_RESTORE_DIR"

if [ $? != 0 ]; then
  printf "Execution error $?"
  exit 1
fi

echo ::set-output name=result::`cat /tmp/trybe-results/evaluation_result.json | base64 -w 0`
echo ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
