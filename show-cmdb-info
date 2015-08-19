#!/bin/bash

# Usage: show-cmdb-info [-c]
# Display server information that may be requested for CMDB entries or inventory.
# Options:
#   -c	Ouput in csv format.

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

FIELD_SEPARATOR=': '

# Pass in -c for CSV format
[ "$1" = '-c' ] && FIELD_SEPARATOR=','

# Host name
echo "Hostname${FIELD_SEPARATOR}$(uname -n)"
echo "FQDN${FIELD_SEPARATOR}$(hostname -f)"

# System model, product, serial
dmidecode -t system | egrep 'Manufacturer:|Product Name:|Serial Number:' | sed 's/^\s*//' | sed "s/: /${FIELD_SEPARATOR}/"

# OS, kernel, platform.
echo "Release${FIELD_SEPARATOR}$(cat /etc/redhat-release)"
echo "Kernel Release${FIELD_SEPARATOR}$(uname -r)"
echo "Architecture${FIELD_SEPARATOR}$(uname -m)"

# Memory:
# Assumes MB are being reported by dmidecode.
MEMORY_IN_MB=$(dmidecode --type memory | grep -e '^\sSize:' | grep -v "No" | awk '{sum+=$2} END{printf("%d\n",sum)}')
MEMORY_IN_GB=$(($MEMORY_IN_MB / 1024))
echo "Memory in GB${FIELD_SEPARATOR}${MEMORY_IN_GB}"

# CPU info:
TOTAL_PHYSICAL_CPUS=0
TOTAL_CORES=0
TOTAL_THREADS=0
echo "CPU Model${FIELD_SEPARATOR}$(cat /proc/cpuinfo | grep 'model name' | cut -f2 -d: | sort -u | sed 's/^\s*//')"
for PHYSICAL_CPU in $(cat /proc/cpuinfo | grep 'physical id' | sort -u | awk '{print $NF}')
do
  CORES=$(cat /proc/cpuinfo | grep -E -m1 -A6 "physical.*:\ ${PHYSICAL_CPU}$" | grep -i 'cpu cores' | awk '{print $NF}')
  THREADS=$(grep 'physical id' /proc/cpuinfo | grep ": ${PHYSICAL_CPU}$" | wc -l)
  echo "CPU ${PHYSICAL_CPU} Cores${FIELD_SEPARATOR}${CORES}"
  echo "CPU ${PHYSICAL_CPU} Threads${FIELD_SEPARATOR}${THREADS}"
  TOTAL_PHYSICAL_CPUS=$(($TOTAL_PHYSICAL_CPUS + 1))
  TOTAL_CORES=$(($TOTAL_CORES + $CORES))
  TOTAL_THREADS=$(($TOTAL_THREADS + $THREADS))
done
echo "Total Physical CPUs${FIELD_SEPARATOR}${TOTAL_PHYSICAL_CPUS}"
echo "Total Cores${FIELD_SEPARATOR}${TOTAL_CORES}"
echo "Total Threads${FIELD_SEPARATOR}${TOTAL_THREADS}"

echo "Storage assigned to volume groups in GB${FIELD_SEPARATOR}$(vgs --units g --noheadings 2>&1 | grep -v "^|" | grep -v 'Could' | awk '{print $6}' | cut -f1 -d. | awk '{sum+=$1} END{printf("%d\n",sum)}')"

# NICS
echo "Network interfaces${FIELD_SEPARATOR}$(netstat -i | egrep -v 'Iface|Interface' | awk '{print $1}' | grep -v "^lo$" | sort | xargs)"
echo "IP Addresses${FIELD_SEPARATOR}$(ip -4 -o addr | awk '{print $4}' | cut -f1 -d/ | grep -v '127.0.0.1' | xargs)"

# Timezone
echo "Timezone${FIELD_SEPARATOR}$(date +%Z)"
