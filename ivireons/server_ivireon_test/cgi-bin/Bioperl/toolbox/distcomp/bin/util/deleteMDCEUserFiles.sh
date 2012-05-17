#!/bin/sh

# Copyright 2008-2010 The MathWorks, Inc.

#---------------------------------------------
# Delete all files related to the mdce service that are owned by either the
# invoking user or MDCEUSER.  This script should be invoked via sudo whenever
# MDCEUSER is defined.
#
# The environment variables CHECKPOINTBASE, LOGBASE and SECURITY_DIR need to
# be defined before calling this script.
#---------------------------------------------

# Make sure we don't accidentally delete any files by checking whether
# environment variables are defined.
# Exit immediately upon failure.

if [ -n "$CHECKPOINTBASE" ] ; then 
    # Directories must not end with a forward slash in order for this to work on
    # sol64.
    rm -rf "$CHECKPOINTBASE"/*_jobmanager_log || exit 1
    rm -rf "$CHECKPOINTBASE"/*_lookup_log     || exit 1
    rm -rf "$CHECKPOINTBASE"/*_mlworker_log   || exit 1
    rm -rf "$CHECKPOINTBASE"/*_phoenix_log    || exit 1
    rm -rf "$CHECKPOINTBASE"/*_sharedvm_log   || exit 1
fi
if [ -n "$LOGBASE" ] ; then
    rm -f "$LOGBASE"/jobmanager_*.log         || exit 1
    rm -f "$LOGBASE"/worker-*.log             || exit 1
    rm -f "$LOGBASE"/mdce-service.log         || exit 1
fi
if [ -n "$SECURITY_DIR" ]; then
    rm -f "$SECURITY_DIR"/private             || exit 1
    rm -f "$SECURITY_DIR"/public              || exit 1
fi
