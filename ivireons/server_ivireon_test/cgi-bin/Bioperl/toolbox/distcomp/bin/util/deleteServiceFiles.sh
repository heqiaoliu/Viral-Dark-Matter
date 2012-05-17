#!/bin/sh

# Copyright 2008 The MathWorks, Inc.

#---------------------------------------------
# Delete all files related to the mdce service
#
# The environment variables UTILBASE, CHECKPOINTBASE, LOGBASE, PIDFILE and
# LOCKFILEs need to be defined before calling this script.
#
# MDCEUSER also needs to be defined whenever appropriate.
#---------------------------------------------

deleteAllServiceFilesOrExit() {
    if [ -n "$MDCEUSER" ] ; then
        sudo -u $MDCEUSER "$UTILBASE"/deleteMDCEUserFiles.sh
        if [ $? -ne 0 ]; then
            echo "Unable to delete files as user $MDCEUSER."
            exit 1;
        fi
    else
        "$UTILBASE"/deleteMDCEUserFiles.sh
        if [ $? -ne 0 ]; then
            echo "Unable to delete files."
            exit 1;
        fi
    fi
    
    
    "$UTILBASE"/deleteInvokingUserFiles.sh
    if [ $? -ne 0 ]; then
        echo "Unable to delete files."
        exit 1;
    fi
}
