#!/bin/bash

# This script will collect information on a running system and hopefully
# gather something useful for later analysis.

# Copyright (c) 2013 Espen Fjellvær Olsen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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