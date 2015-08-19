#!/bin/bash

# Display WWPNs on a Linux server.

[ -d "/sys/class/fc_host" ] && cat /sys/class/fc_host/*/port_name | sed 's/^0x//; s/\(.\{2\}\)/&:/g; s/:$//'

