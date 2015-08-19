#!/bin/bash

# This script creates a backup of a RHEV-M node.

# Where to place the backups.
BACKUP_DIR=/var/rhevm-backups/$(uname -n)

# Set BACKUP_REPORTS to true if you are using RHEV reports, otherwise set it to false.
BACKUP_REPORTS=false

# How many days to retain the backup files.
DAYS_TO_RETAIN_BACKUPS=7

# Use the date format from the RedHat documentation.
BACKUP_DATE=$(date | sed 's/ /_/g' | sed 's/\:/_/g')

# The backup files
CONFIG_BACKUP_FILE="$BACKUP_DIR/config_${BACKUP_DATE}.tar.gz"
REPORTS_CONFIG_BACKUP_FILE="$BACKUP_DIR/reports_config_${BACKUP_DATE}.tar.gz"

# Run as root
[ "$EUID" -eq 0 ] || {
  echo 'Please run with sudo or as root.'
  exit 1
}

# Create the backup backup directory if it does not exist.
[ -d "$BACKUP_DIR" ] || {
  mkdir -p $BACKUP_DIR
  chmod 775 $BACKUP_DIR
  chgrp wheel $BACKUP_DIR
}

# Backup the database
cd /usr/share/ovirt-engine/dbscripts
./backup.sh -s localhost -d engine -u postgres -l $BACKUP_DIR

# Compress the backup.
gzip $BACKUP_DIR/*.sql

# Backup the config files
CONFIG_FILES="/etc/ovirt-engine/ /etc/sysconfig/ovirt-engine /etc/yum/pluginconf.d/versionlock.list /etc/pki/ovirt-engine/ /usr/share/ovirt-engine/conf/iptables.* /usr/share/ovirt-engine/dbscripts/create_db.sh.log /var/lib/ovirt-engine/backups /var/lib/ovirt-engine/deployments /root/.rnd"

# Create the tar file.
tar czPf $CONFIG_BACKUP_FILE $CONFIG_FILES

if $BACKUP_REPORTS
then
  CONFIG_FILES_FOR_REPORTS="/usr/share/ovirt-engine-reports/reports/users/rhevm-002dadmin.xml /usr/share/ovirt-engine-reports/default_master.properties /usr/share/jasperreports-server-pro/buildomatic"
  tar czPf $REPORTS_CONFIG_BACKUP_FILE $CONFIG_FILES_FOR_REPORTS
fi

# Remove old backup files
tmpwatch --mtime ${DAYS_TO_RETAIN_BACKUPS}d $BACKUP_DIR

# This is how to restore:
#   cd /usr/share/ovirt-engine/dbscripts
#   ./restore.sh -s localhost -u postgres -d engine -f engine_Tue_Mar_19_07_06_42_EDT_2013.sql -r
# 
# Details at:
#   https://access.redhat.com/site/solutions/339453
