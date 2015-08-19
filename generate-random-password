#!/bin/bash

# Usage: generate-random-password [NUMBER_OF_PASSWORDS] [PASSWORD_LENGTH]
# Generate random passwords using openssl.
# Optionally pass in the number of passwords you want to generate and the length.
# Default number of passwords is one.  The default and maximum length is 64 characters.
#
# Example:
#   Generate 3 passwords that are 8 characters long.
#     generate-random-password 3 8

NUMBER_OF_PASSWORDS=$1
[ -n "$NUMBER_OF_PASSWORDS" ] || NUMBER_OF_PASSWORDS=1

PASSWORD_LENGTH=$2
[ -n "$PASSWORD_LENGTH" ] || PASSWORD_LENGTH=64

for x in $(seq 1 $NUMBER_OF_PASSWORDS)
do
  openssl rand -base64 48 | cut -c1-${PASSWORD_LENGTH}
done
