#!/bin/bash -e
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

mvn versions:set -DnewVersion=$1 -DgenerateBackupPoms=false
