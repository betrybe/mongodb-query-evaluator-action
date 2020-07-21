#!/bin/sh -l
set -x

IMPORT_DIR=$1
CHALLENGES_DIR=$2

/scripts/importdb.sh "$IMPORT_DIR"
/scripts/generate_result.sh "$CHALLENGES_DIR"

if [ $? != 0 ]; then
  echo "Execution error"
  exit 1
fi

echo ::set-output name=result::`cat result.json | base64 -w 0`
echo ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
