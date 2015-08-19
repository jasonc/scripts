#!/bin/bash

# Usage: tail-db2diag
# Performs a tail -f on the current db2 diag log file.

DB2_DIAG_LOG=$(ls -rt /db2/*/db2dump/db2diag* 2>/dev/null | tail -1)

if [ -e "$DB2_DIAG_LOG" ]
then
  # Show what file we're tailing.
  echo $DB2_DIAG_LOG
  echo

  # Tail the log file.
  tail -f $DB2_DIAG_LOG
else
  echo "No db2 diag log file found."
  exit 1
fi
