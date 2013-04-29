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
exec 6>&1
exec 2>/dev/null

tmp=`mktemp -d`
logDate=2 # Days of logs to collect
version=1

# Try to collect relevant information about the OS
function collectSystemInformation {
    exec > $tmp/systemInformation

    echo "*************************************"
    echo "*** Standard system information ***"
    echo "*************************************"
    uname -a
    type lsb_release &> /dev/null && lsb_release -a
    cat /etc/*release
    cat /etc/*version
    uptime

    echo "*************************************"
    echo "*** Kernel messages ***"
    echo "*************************************"
    dmesg

    echo "*************************************"
    echo "*** Hardware information ***"
    echo "*************************************"
    cat /proc/cpuinfo
    echo
    free -m
    
    echo "*********************************"
    echo "*** Virtual memory statistics ***"
    echo "*********************************"
    vmstat

    echo "***********************************"
    echo "*** Top 5 CPU eating process ***"
    echo "***********************************"
    ps auxf | sort -nr -k 3 | head -5 

    echo "***********************************"
    echo "*** Top 5 memory eating process ***"
    echo "***********************************"
    ps auxf | sort -nr -k 4 | head -5 

    echo "*************************************"
    echo "*** Open files ***"
    echo "*************************************"
    lsof -n
    
}

function collectUsers {
    exec > $tmp/userInformation
    
    echo "**************************************"
    echo "*** Users logged in ***"
    echo "**************************************"
    who -H -a
    
    echo "**************************************"
    echo "*** Last logged in users ***"
    echo "**************************************"
    last
}

# Collect information about the network
function collectNetworkInformation {
    exec > $tmp/networkInformation

    echo "**************************************"
    echo "*** Network routing ***"
    echo "**************************************"
    netstat -nr

    echo "**************************************"
    echo "*** Interface information  ***"
    echo "**************************************"
    
    /sbin/ifconfig -a

    echo "**************************************"
    echo "*** Interface traffic information ***"
    echo "**************************************"
    netstat -i    

    echo "**************************************"
    echo "*** Resolv.conf ***"
    echo "**************************************"
    cat /etc/resolv.conf

    echo "**************************************"
    echo "*** Open network connections  ***"
    echo "**************************************"   
    netstat -lapn  
}

# Collect information about running processes
function collectProcessInformation {
    exec > $tmp/processes
    echo "**************************************"
    echo "*** Running processes ***"
    echo "**************************************"
    ps auxwwwf

    echo "**************************************"
    echo "*** Directory of running processes ***"
    echo "**************************************"
    ls -l /proc/*/cwd

    echo "**************************************"
    echo "*** Executable of running processes ***"
    echo "**************************************"
    ls -l /proc/*/exe

    echo "**************************************"
    echo "*** Arguments of running processes ***"
    echo "**************************************"

    grep -a ^ /proc/*/cmdline
}


# Collect logs up to $logDate days old
function collectLogs {
    mkdir $tmp/logs
    find /var/log -mtime -$logDate -exec cp {} $tmp/logs/ \; # Nested folders will blow up...
}


collectSystemInformation
collectUsers
collectNetworkInformation
collectProcessInformation
collectLogs

tar cfz InformationCollector-$(date +%y%m%d).tgz $tmp
rm -rf $tmp