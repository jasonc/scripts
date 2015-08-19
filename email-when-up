#!/bin/bash

# Usage: email-when-up -e EMAIL_ADDRESS -h HOST
# This script send an email when the server/host/device is reachable over the network.

usage() {
  echo "Usage: $0 -e EMAIL_ADDRESS -h HOST" >&2
  exit
}

while getopts ":e:h:" opt; do
  case "${opt}" in
    e)
      EMAIL_ADDRESS=${OPTARG}
      ;;
    h)
      HOST=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${EMAIL_ADDRESS}" ] || [ -z "${HOST}" ]
then
  usage
fi

# Loop until the server is up.
SECONDS_TO_SLEEP=60
while [ true ]
do
  ~/scripts/ping-host $HOST >/dev/null 2>&1
  if [ "$?" -eq 0 ]
  then
    echo "${HOST} is up!  $(date)"
    echo "${HOST} is up!  $(date)" | mailx -s "${HOST} is up." $EMAIL_ADDRESS
    exit
  else
    echo "$(date) ${HOST} is still down."
  fi
  sleep $SECONDS_TO_SLEEP
done
