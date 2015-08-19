#!/bin/bash

# This script displays the switch, port, and VLAN for each of the physical
# network interfaces on a Linux server that is connected to Cisco networking
# gear.
#
# Specific interfaces can be passed in on the command line.  Other interfaces
# will be ignored.

# Set a timeout on the tcpdump command.
TIMEOUT_SECONDS=60

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

# If arguments are supplied, they are a list of NICs.
NICS=$@
[ -z "$NICS" ] && {
  # Get a list of physical NICS on the server that are UP.  Also, ignore bonded,
  # loopback, usb, virtual, tagged (@), and bridged interfaces.
  NICS=$(ip link | grep ^[0-9] | grep 'state UP' | cut -d: -f2 | egrep -v 'bond|lo|usb|@|vnet|vir|br' | sort | xargs)
}

# Loop through the NICs.
for NIC in $NICS
do
  echo $NIC
  timeout $TIMEOUT_SECONDS tcpdump -v -i $NIC -s 1500 -c 1 'ether[20:2] == 0x2000' 2>&1 |egrep 'Device-ID|Port-ID|VLAN' | awk '{print $NF}' | sed "s/'//g"

  [ "${PIPESTATUS[0]}" -eq 124 ] && echo 'tcpdump timed out.'

  echo
done
