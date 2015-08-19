#!/bin/bash

# Show which I/O schedulers are currently in use.

[ -d "/sys/block" ] && cat /sys/block/*/queue/scheduler | grep -v none | cut -f 2 -d[ | cut -f1 -d] | sort -u
