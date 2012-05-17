#!/bin/sh
# Helper shell script to retrieve the name of a given process from its PID

# Copyright 2006 The MathWorks, Inc.
# $Revision: 1.1.6.4 $ $Date: 2008/10/17 20:32:24 $

computer=$1
pid=$2

case $computer in
    GLNX*)
        name=`/bin/ps -p $pid -o cmd=`
        ;;
    SOL*)
        name=`/usr/bin/ps -p $pid -o args=`
        ;;
    MAC*)
        # On MAC, this may leave extra blank lines - but these will be stripped
        # by the call to "strtrim". Add "-w -w" to get the full process name
        name=`/bin/ps -w -w -p $pid -o command=`
        ;;
    *)
        echo "Unknown computer type: \"$computer\""
        exit 1
        ;;
esac

if [ "$name" = "" ]
then
    echo "Couldn't find process $pid"
    exit 1
else
    # Protect against interference with the textual output
    echo "|||${name}|||"
fi
