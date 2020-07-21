#!/bin/bash

for entry in challenges/*.js
do
  # Get challenge name
  challengeName=$(echo "$entry" | sed -e "s/.js//g" | sed -e "s/challenges\///g")
  # Build path to results dir
  resultFile="challenges/results/$challengeName"
  # Exec query
  ./scripts/exec.sh "$entry" &> "$resultFile"
  # Check result with the expected
  if [[ ! -z $(diff "$resultFile" ".challenges-expected/$challengeName") ]]; then
    echo "$challengeName failed"
    continue
  fi

  echo "$challengeName passed"
done