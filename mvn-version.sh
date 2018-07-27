#!/bin/bash -e
mvn versions:set -DnewVersion=$1 -DgenerateBackupPoms=false
