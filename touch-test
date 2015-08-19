#!/bin/bash

# Usage: touch-test
# Touches and deletes a file on each of the locally mounted file systems. 
# This can help point out read-only mounts and poorly performing mounts.

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

TEST_FILE='touch-test-file'

START=$(date)
START_SECONDS=$(date +%s)

for MOUNT in $(df -lP | egrep -v '^Filesystem|tmpfs' | awk '{print $NF}')
do
  TEST_FILE_ON_MOUNT="${MOUNT}/${TEST_FILE}"
  echo "$(date) - Touching $TEST_FILE_ON_MOUNT"
  touch $TEST_FILE_ON_MOUNT
  rm $TEST_FILE_ON_MOUNT
  echo "$(date) - Removed $TEST_FILE_ON_MOUNT"
done

END=$(date)
END_SECONDS=$(date +%s)
TOTAL_SECONDS=$(($END_SECONDS - $START_SECONDS))

echo
echo "Start: $START"
echo "End:   $END"
echo "Total: $TOTAL_SECONDS seconds"
