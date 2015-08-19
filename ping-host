#!/bin/bash

# Usage: ping-host HOST [HOSTN]...
# Retuns 0 if the hosts respond to ping or 1 if any of them fail to respond.
#
# Supported operating systems: Linux, Mac, BSDs, Solaris.


# Help
if [ -z "$1" ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]
then
  echo 'Usage: ping-host HOST [HOSTN]...' >&2
  echo 'Retuns 0 if the hosts respond to ping or 1 if any of them fail to respond.' >&2
  exit
fi

# What OS are we on?
OS=$(uname -s)

if [ "$OS" = 'SunOS' ]
then
  # Solaris
  PING='ping -t 10'
  PING_SUFFIX_ARGS='1'
  GREP_PATTERN='no'
else
  # Linux / Mac
  PING='ping -c 1 -W 1'
  PING_SUFFIX_ARGS=""
  GREP_PATTERN='100%'
fi

# Hope for the best, prepare for the worst.
RETURN_CODE=0

# Loop through the hosts provided on the command line.
for HOST in $@
do
  PING_RESULT=$($PING $HOST $PING_SUFFIX_ARGS 2>&1 | egrep "$GREP_PATTERN|unknown host" | cut -d, -f3 | wc -l)
  [ "$PING_RESULT" -eq 0 ] || {
    RETURN_CODE=1
    echo "$HOST down"
  }
done

exit $RETURN_CODE
