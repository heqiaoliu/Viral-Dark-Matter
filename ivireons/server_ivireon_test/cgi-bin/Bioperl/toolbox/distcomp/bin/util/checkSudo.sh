#!/bin/sh

# Copyright 2007 The MathWorks, Inc.

#================================================================
#
# This script is meant to be run using sudo to verify the sudo setup for
# starting the MATLAB Distributed Computing Server.
#
#================================================================

# The abnormal exit status of this script should be > 1 so it doesn't get
# confused with sudo's error exit status.

# Check for the presence of environmental variables that are defined by 
# the caller.
if [ -z "$TESTVAR1" -o -z "$TESTVAR2" ]; then
    exit 2;
fi
