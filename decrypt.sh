#!/bin/bash -e
openssl enc -in $1 -d -aes256 -k $2
