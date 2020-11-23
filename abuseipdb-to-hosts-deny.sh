#!/bin/bash 

# This script maintains a list of the AbuseIPDB Blacklist IP addresses in the hosts.deny file.
# This script should be executed by a job scheduler such as cron.
# Here is an example cron entry that will run this script once a day:
#  0 0 * * * /path/to/abuseipdb-to-hosts-deny.sh

# User-defined variables:

# Replace the value with your YOUR AbuseIPDB API key.  (See https://docs.abuseipdb.com/)
API_KEY="REPLACE_ME"

# The confidence level is a rating on a scale of 0 to 100 of how confident
# abuseipdb is that an IP address is entirely malicious.
CONFIDENCE_LEVEL="90"

# The location of the hosts.deny file on this system.
# By default, it is /etc/hosts.deny. Unless you have a special
# configuration, leave this at the default setting.
HOSTS_DENY='/etc/hosts.deny'

#################### STOP ####################
#   Do not edit anything below this line.    #
#################### STOP ####################


# Script variables.
API_URL="https://api.abuseipdb.com/api/v2/blacklist"
START_MARKER='# START abuseipdb blacklist'
END_MARKER='# END abuseipdb blacklist'
TMP_BLACKLIST=$(mktemp)
TMP_HOSTS_DENY=$(mktemp)

# This function deletes the tmp files.
cleanup() {
  rm ${TMP_BLACKLIST} > /dev/null 2>&1
  rm ${TMP_HOSTS_DENY} > /dev/null 2>&1
}

# This function displays the message passed to it, cleans up, and exits with an error code.
fail() {
  echo "ERROR: ${@}"
  cleanup
  exit 1
}

# Download the blacklist.
curl -sG ${API_URL} \
  -d confidenceMinimum=${CONFIDENCE_LEVEL} \
  -d plaintext \
  -H "Key: ${API_KEY}" \
  -H "Accept: application/json" > ${TMP_BLACKLIST}

# Check to see if the curl command failed.
if [[ ${?} -ne 0 ]]
then
  fail "Unable to download blacklist."
fi

# If the blacklist file contains the text "error", then we do NOT have a list of IP addresses.
grep -i error ${TMP_BLACKLIST} >/dev/null

if [[ ${?} -eq 0 ]]
then
  fail "Error downloading blacklist."
fi

# Append a blank line to the end of the blacklist to ensure the end marker is on a new line.
echo '' >> ${TMP_BLACKLIST}

# Insert the text "ALL: " at the beginning of each line / IP address.
sed -i 's/^/ALL: /' ${TMP_BLACKLIST}

# Create a copy of the hosts.deny file.
cp ${HOSTS_DENY} ${TMP_HOSTS_DENY}

# Add our start and end markers in the hosts.deny file if they don't already exist.
grep "^${START_MARKER}" ${TMP_HOSTS_DENY} >/dev/null

if [[ ${?} -ne 0 ]]
then
  echo "Adding start and end markers to ${TMP_HOSTS_DENY}."
  echo "${START_MARKER}" >> ${TMP_HOSTS_DENY}
  echo "${END_MARKER}" >> ${TMP_HOSTS_DENY}
fi

# Delete existing lines between the start and end markers.
sed -i "/^${START_MARKER}/,/^${END_MARKER}/{//!d}" ${TMP_HOSTS_DENY}

# Insert the blacklist IP lines after the start marker.
sed -i "/^${START_MARKER}/r ${TMP_BLACKLIST}" ${TMP_HOSTS_DENY}

# Overwrite the hosts.deny with the new file.
cp ${TMP_HOSTS_DENY} ${HOSTS_DENY}

if [[ ${?} -ne 0 ]]
then
  fail "Could not copy ${TMP_HOSTS_DENY} to ${HOSTS_DENY}."
fi

# Clean up
cleanup

# Bye
exit 0
