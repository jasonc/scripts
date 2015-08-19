#!/bin/bash

# Usage: show-total-disk-space-used
# Shows how much local disk space is in use by the server.

function round() {
  # Returns a rounded number
  local INTEGER=$(echo $1 | cut -f1 -d.)
  [ -z "$INTEGER" ] && INTEGER=0

  local DECIMAL=$(echo $1 | cut -s -f2 -d.)
  [ -z "$DECIMAL" ] && DECIMAL=0
  [ "$DECIMAL" -gt 4 ] && INTEGER=$(($INTEGER + 1))
  echo $INTEGER
}

# Disk size used in kb, summed
KB=$(df -lkP | awk '{print $3}' | grep -v Used | awk '{sum+=$1} END{printf("%d\n",sum)}')

# Convert size to MB, GB, and TB
MB=$(round $(echo $KB/1024           | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))
GB=$(round $(echo $KB/1024/1024      | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))
TB=$(round $(echo $KB/1024/1024/1024 | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))

# Use the largest human readable size to display
if [ "$TB" -gt 0 ]
then
  TOTAL_DISK_SPACE_USED="${TB}T"
elif [ "$GB" -gt 0 ]
then
  TOTAL_DISK_SPACE_USED="${GB}G"
elif [ "$MB" -gt 0 ]
then
  TOTAL_DISK_SPACE_USED="${MB}M"
else
  TOTAL_DISK_SPACE_USED="${KB}K"
fi

echo -e "$(uname -n)\t${TOTAL_DISK_SPACE_USED}"
