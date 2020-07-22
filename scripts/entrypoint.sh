#!/bin/sh -l

IMPORT_DIR=$1
CHALLENGES_DIR=$2

git clone https://github.com/$GITHUB_REPOSITORY.git /github/master-repo/

cd /
scripts/importdb.sh "/github/workspace/$IMPORT_DIR"
scripts/generate_result.sh "/github/workspace/$CHALLENGES_DIR" "/github/master-repo/.challenges-expected"

if [ $? != 0 ]; then
  printf "Execution error $?"
  exit 1
fi

echo ::set-output name=result::`cat /tmp/trybe-results/evaluation_result.json | base64 -w 0`
echo ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
