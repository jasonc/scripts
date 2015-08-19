#!/bin/bash 

# Usage: prettify-multipath
#
# Real world Usage:
#   cp /etc/multipath.conf /etc/multipath.conf.$(date +%F) && \
#   prettify-multipath | tee -a /etc/multipath.conf && vi /etc/multipath.conf
#
# Generates multipath configuration stanzas containing aliases in this format:
#   /dev/mapper/vgname_last-4-digits-of-WWID
#
# Example:
#   Before prettify:
#     /dev/mapper/mpathX or /dev/mapper/360000000000000000000000000001234
#   After prettify:
#     /dev/mapper/datavg_1234

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

MULTIPATH_CONF_FILE='/etc/multipath.conf'

[ -e "$MULTIPATH_CONF_FILE" ] || {
  echo "$MULTIPATH_CONF_FILE not found.  Exiting."
  exit 1
}

# Run the multipath command once and cache the output.
MULTIPATH_TEMP_FILE=$(mktemp --suffix -$(basename $0))
multipath -ll 2>&1 > ${MULTIPATH_TEMP_FILE}

# Loop through the volume groups. 
for VG in $(vgs --noheadings 2>&1 | awk '{print $1}')
do
  # Find the PVs in the VG and clean up the PV names by dropping any partition numbers.  (mpath0p2 cleans up to mpath0, etc.)
  for PV in $(vgdisplay -v $VG 2>&1 | grep "PV Name" | grep -v 'unknown' | awk '{print $NF}' | sed 's/p[0-9]$//' | awk -F/ '{print $NF}' | sed 's/dm-name-//')
  do
    # Extract the WWID from the multipath output.
    WWID="\"$(cat ${MULTIPATH_TEMP_FILE} | grep "${PV} " | grep "dm-" | cut -f2 -d ' ' | sed 's/(//' | sed 's/)//')\""
    LAST_FOUR_DIGITS=$(echo ${WWID} | cut -c 31-34)
    LAST_FIVE_DIGITS=$(echo ${WWID} | cut -c 30-34)

    # Only act on those not configured in ${MULTIPATH_CONF_FILE}
    if [ $(grep -c ${WWID} ${MULTIPATH_CONF_FILE}) -eq 0 ]
    then
      ALIAS="${VG}_${LAST_FOUR_DIGITS}"
      # On rare occasions, the last four digits of a WWID in a volume group can be repeated.  If so, use the last five digits.
      if [ $(grep -c ${ALIAS} ${MULTIPATH_CONF_FILE}) -gt 0 ]
      then
        ALIAS="${VG}_${LAST_FIVE_DIGITS}"
      fi
      echo "  multipath {"
      echo "    wwid ${WWID}"
      echo "    alias ${ALIAS}"
      echo "  }"
    fi
  done
done

rm ${MULTIPATH_TEMP_FILE}
