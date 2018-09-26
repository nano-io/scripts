#!/bin/bash -e
export IGNORE_FILES=$(ls -p | grep -v /)

detect_changed_folders() {
    if [[ "${DRONE_PULL_REQUEST}" ]]; then 
        folders=$(git --no-pager diff --name-only FETCH_HEAD FETCH_HEAD~1 | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq); 
    else 
        folders=$(git --no-pager diff --name-only HEAD~1 | sort -u | awk 'BEGIN {FS="/"} {print $1}' | uniq); 
    fi
    export changed_components=$folders
}

