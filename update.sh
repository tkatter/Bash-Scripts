#! /bin/bash

releaseFile=/etc/os-release
logfile=/var/log/updaterScriptLogs/updater.log
errorlog=/var/log/updaterScriptLogs/updater_errors.log

checkExitStatus() {
    if [ $? -ne 0 ]
    then
        /usr/bin/echo "An error occurred, please check the $errorlog file."
    fi
}

if grep -q "Debian" $releaseFile || grep -q "Ubuntu" $releaseFile
then
    # The host is based on Debian or Ubuntu.
    # Run the indicated distribution's package manager:
    sudo apt update 1>>$logfile 2>>$errorlog
    checkExitStatus
    sudo apt upgrade -y 1>>$logfile 2>>$errorlog
    checkExitStatus
    /usr/bin/echo "This was ran at $(date)." 1>>$errorlog
    /usr/bin/echo "This was ran at $(date)." 1>>$logfile
fi
