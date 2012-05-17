#!/bin/sh

# Copyright 2008 The MathWorks, Inc.

#---------------------------------------------
# Delete all files related to the mdce service that are owned by the invoking
# user.  This script should never be invoked via sudo.
#
# The environment variables PIDFILE and LOCKFILEs need
# to be defined before calling this script.
#---------------------------------------------

# Make sure we don't accidentally delete any files by checking whether
# environment variables are defined.

if [ -n "$PIDFILE" ]; then
    rm -f "$PIDFILE" || exit 1
fi
if [ -n "$LOCKFILE" ]; then
    rm -f "$LOCKFILE" || exit 1
fi

