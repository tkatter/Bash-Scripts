#! /bin/bash

# EXIT CODES
# 1 = invailid amount of arguments (requires 2).
# 2 = Rsync is not installed on your system.


# Check to make sure the user has entered exactly two arguments
if [ $# -ne 2 ]
then
    $(which echo) "Usage: backup.sh <source_directory> <target_directory>"
    $(which echo) "Please try again."
    exit 1
fi

# Check to see if rsync is installed
if ! command -v rsync > /dev/null 2>&1
then
    $(which echo) "This script requires rsync to be installed."
    $(which echo) "Please use your distribution's package manager to install it and try again."
    exit 2
fi

# Capture the current date, and store it in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

rsync_options="-avb --backup-dir $2/$current_date --delete --dry-run"

# ARGUMENTS:
# $1 = SOURCE DIRECTORY
# $2 = TARGET DIRECTORY
$(which rsync) $rsync_options $1 $2/current >> backup_$current_date.log

