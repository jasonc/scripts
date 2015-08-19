#!/bin/bash

# Usage: show-disk-space-used-by-vg [VG]...
# Shows how much disk space is in use by each volume group.
# Specific volume groups can be passed in on the command line.  Other volume groups 
# will be ignored.

# If a list of volume groups is provided, use those.
VGS=$@
[ -z "$VGS" ] && {
  # Run as root
  [ "$EUID" -eq 0 ] || {
    echo 'Please run with sudo or as root.'
    exit 1
  }
  # Get all volume groups.
  VGS=$(vgs --noheadings | awk '{print $1}')
}

function round() {
  # Returns a rounded number
  local INTEGER=$(echo $1 | cut -f1 -d.)
  [ -z "$INTEGER" ] && INTEGER=0

  local DECIMAL=$(echo $1 | cut -s -f2 -d.)
  [ -z "$DECIMAL" ] && DECIMAL=0
  [ "$DECIMAL" -gt 4 ] && INTEGER=$(($INTEGER + 1))
  echo $INTEGER
}

TMPFILE=$(mktemp --suffix -$(basename $0))

for VG in $VGS
do
  # Disk size used in kb, summed
  KB=$(df -kP | grep ${VG}- | awk '{sum+=$3} END{printf("%d\n",sum)}')

  # Convert size to MB, GB, and TB
  MB=$(round $(echo $KB/1024           | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))
  GB=$(round $(echo $KB/1024/1024      | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))
  TB=$(round $(echo $KB/1024/1024/1024 | bc -l | sed -e "s/\(\.[0-9]\).*/\1/g"))

  # Use the largest human readable size to display
  if [ "$TB" -gt 0 ]
  then
    echo "$VG ${TB}T" >> $TMPFILE
  elif [ "$GB" -gt 0 ]
  then
    echo "$VG ${GB}G" >> $TMPFILE
  elif [ "$MB" -gt 0 ]
  then
    echo "$VG ${MB}M" >> $TMPFILE
  else
    echo "$VG ${KB}K" >> $TMPFILE
  fi
done

cat $TMPFILE | column -t
rm $TMPFILE 2>/dev/null
