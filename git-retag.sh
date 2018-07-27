#!/bin/bash 
echo "Deleting local tag: $1"
git tag -d $1
echo "Deleting remote tag: $1"
git push origin :$1
set -e
echo "Creating local tag: $1"
git tag $1
echo "Pushing remote tag: $1"
git push origin $1
