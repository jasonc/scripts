#!/bin/bash

# Usage: $0 [ -s SOURCE_DEVICE ] [ -p PARTNER_SLAVE_DEVICE ] [ -b BOND_DEVICE ] [-r]
# Takes a configured NIC and partners it with a second NIC to create a bonded pair.

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

usage() {
  echo "Usage: $0 [ -s SOURCE_DEVICE ] [ -p PARTNER_SLAVE_DEVICE ] [ -b BOND_DEVICE ] [-r]" >&2
  echo >&2
  echo 'Arguments: ' >&2
  echo '  -s	The source NIC that is already configured.  Default value if not specified: eth0' >&2
  echo '  -p	The second NIC to pair with the source NIC.  Default value if not specified: eth1' >&2
  echo '  -b	The bond to create.  Default value if not specified: bond0' >&2
  echo '  -r	Restart networking after the bond has been configured.' >&2
  exit 1
}

# Set defaults
SOURCE_SLAVE_DEVICE=eth0
PARTNER_SLAVE_DEVICE=eth1
BOND_DEVICE=bond0
RESTART_NETWORKING=false

while getopts ":s:p:b:r" opt; do
  case "${opt}" in
    s)
      SOURCE_SLAVE_DEVICE=${OPTARG}
      ;;
    p)
      PARTNER_SLAVE_DEVICE=${OPTARG}
      ;;
    b)
      BOND_DEVICE=${OPTARG}
      ;;
    r)
      RESTART_NETWORKING=true
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# Configuration file variables.
IFCFG_PATH=/etc/sysconfig/network-scripts
BOND_DEVICE_FILE=${IFCFG_PATH}/ifcfg-${BOND_DEVICE}
SOURCE_SLAVE_DEVICE_FILE=${IFCFG_PATH}/ifcfg-${SOURCE_SLAVE_DEVICE}
PARTNER_SLAVE_DEVICE_FILE=${IFCFG_PATH}/ifcfg-${PARTNER_SLAVE_DEVICE}
BONDING_OPTS='mode=1 miimon=50 updelay=100'

function backup_file () {
  if [ -e "$1" ] 
  then
    local BACKUP_FILE="/var/tmp/$(basename ${1}).$(date +%F).$$"
    echo "Backing up $1 to ${BACKUP_FILE}"
    cp $1 $BACKUP_FILE
  fi
}

function exit_if_file_does_not_exist () {
  if [ ! -e "$1" ] 
  then
    echo "$1 does not exist.  Exiting."
    exit 1
  fi
}

function make_slave_device_file () {
  # Pass in slave device, slave device file, bond device.
  local S_DEVICE=$1
  local S_FILE=$2
  local BOND_D=$3
  echo "DEVICE=${S_DEVICE}" > $S_FILE
  echo "BOOTPROTO=none" >> $S_FILE
  echo "ONBOOT=yes" >> $S_FILE
  echo "MASTER=${BOND_D}" >> $S_FILE
  echo "SLAVE=yes" >> $S_FILE
  echo "USERCTL=no" >> $S_FILE
  echo "NM_CONTROLLED=no" >> $S_FILE
} 

# RHEL 5 requires an alias in modprobe.conf.  Add it if needed.
if [ $(cat /etc/redhat-release  | grep -c " 5.") -eq 1 ]
then
  ALIAS_LINE="alias ${BOND_DEVICE} bonding"
  if [ $(grep "${ALIAS_LINE}" /etc/modprobe.conf | grep -v ^# | wc -l) -eq 0 ]
  then
    backup_file /etc/modprobe.conf
    echo "${ALIAS_LINE}" >> /etc/modprobe.conf
  fi
fi

# Create the basic config for the bonded device.
backup_file $BOND_DEVICE_FILE
echo "DEVICE=${BOND_DEVICE}" > $BOND_DEVICE_FILE
echo "ONBOOT=yes" >> $BOND_DEVICE_FILE
echo "BONDING_OPTS=\"${BONDING_OPTS}"\" >> $BOND_DEVICE_FILE
echo "NM_CONTROLLED=no" >> $BOND_DEVICE_FILE

# Take the remaining required configuration from the source device and append it to the bond device.
backup_file $SOURCE_SLAVE_DEVICE_FILE
exit_if_file_does_not_exist $SOURCE_SLAVE_DEVICE_FILE
cat $SOURCE_SLAVE_DEVICE_FILE | egrep -v 'DEVICE|NM_CONTROLLED|HWADDR|UUID|ONBOOT|TYPE' >> $BOND_DEVICE_FILE
echo "Created ${BOND_DEVICE_FILE}"

# Create the configuration for the two slave devices.
make_slave_device_file $SOURCE_SLAVE_DEVICE $SOURCE_SLAVE_DEVICE_FILE $BOND_DEVICE
backup_file $PARTNER_SLAVE_DEVICE_FILE
make_slave_device_file $PARTNER_SLAVE_DEVICE $PARTNER_SLAVE_DEVICE_FILE $BOND_DEVICE

if $RESTART_NETWORKING
then
  service network restart
fi
