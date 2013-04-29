#!/bin/bash
# Copyright (c) 2013 Espen Fjellvær Olsen
#
# This script will collect information on a running system and hopefully
# gather something useful for later analysis.
echo "Information collector system"
tmp=`mktemp -d`
logDate=2 # Days of logs to collect

# Try to collect relevant information about the OS
function collectSystemInformation {
    uname -a > $tmp/uname
    cat /etc/*release > $tmp/release
    cat /etc/*version >> $tmp/release
    type lsb_release &> /dev/null && lsb_release -a > $tmp/lsb
    lsof -n > $tmp/lsof
}

# Collect information about the network
function collectNetworkInformation {
    netstat -lapn > $tmp/netstat
    route -n > $tmp/route
    /sbin/ifconfig -a > $tmp/ifconfig
}

# Collect information about running processes
function collectProcessInformation {
    ps auxwwwf > $tmp/ps
    ls -l /proc/*/cwd > $tmp/proc
    ls -l /proc/*/exe >> $tmp/proc
    grep -a ^ /proc/*/cmdline >> $tmp/proc-cmdline   
}


# Collect logs up to $logDate days old
function collectLogs {
    mkdir $tmp/logs
    find /var/log -mtime -$logDate -exec cp {} $tmp/logs/ \; # Nested folders will blow up...
}


collectSystemInfomration
collectNetworkInformation
collectProcessInformation
collectLogs


tar cfz InformationCollector-$(date +%y%m%d).tgz $tmp
rm -rf $tmp