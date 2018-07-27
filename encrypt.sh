#!/bin/bash -e
openssl enc -in $1 -out "$1.crypt" -e -aes256 -k $2
