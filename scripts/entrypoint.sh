#!/bin/sh -l
set -x

IMPORT_DIR=$1

echo "$GITHUB_REPOSITORY"
echo "$GITHUB_ACTOR"
echo "$GITHUB_REF"
ls -l

./importdb.sh "$IMPORT_DIR"
./generate_result.sh

if [ $? != 0 ]; then
  echo "Execution error"
  exit 1
fi

# echo ::set-output name=result::`cat result.json | base64 -w 0`
echo ::set-output name=pr-number::$(echo "$GITHUB_REF" | awk -F / '{print $3}')
