#!/bin/sh

# Copyright 2004-2010 The MathWorks, Inc.

#-----------------------------------------------------------------------------
# Define some general variables about phoenix
#-----------------------------------------------------------------------------
BINBASE="$MDCEBASE/bin/$ARCH"
APPNAME="mdced"
APP_LONG_NAME="MATLAB Distributed Computing Server"
# Don't change this else we will specifically need to remove it in the stop
# command
PIDFILE="$PIDBASE/$APPNAME.pid"
LOCKFILE="$LOCKBASE/$APPNAME"

# Wrapper
WRAPPER_CMD="$BINBASE/$APPNAME"
WRAPPER_CONF="$CONFIGBASE/wrapper-phoenix.config"
MDCE_PLATFORM_WRAPPER_CONF="$CONFIGBASE/wrapper-phoenix-$ARCH.config"

# The actual command needed to run MATLAB

MATLAB_EXECUTABLE=$MATBASE/bin/$ARCH/MATLAB
MATLAB_INITFILE_ARG=-r

#-----------------------------------------------------------------------------
# Export the variables that are REQUIRED by the wrapper-phoenix.config
# file. These variables must be set correctly for the wrapper layer to
# work correctly.
#-----------------------------------------------------------------------------
export JRECMD
export JREFLAGS

export JREBASE
export MATBASE
export JARBASE
export JAREXTBASE
export JINILIB

export MDCEBASE
export LOGBASE
export CHECKPOINTBASE

export HOSTNAME
export ARCH

export WORKER_START_TIMEOUT

export MATLAB_EXECUTABLE
export MATLAB_INITFILE_ARG

export JOB_MANAGER_MAXIMUM_MEMORY
export MDCEQE_JOBMANAGER_DEBUG_PORT
export CONFIGBASE

export DEFAULT_JOB_MANAGER_NAME
export DEFAULT_WORKER_NAME

export JOB_MANAGER_HOST
export BASE_PORT

export LOG_LEVEL

export MDCE_PLATFORM_WRAPPER_CONF

export WORKER_DOMAIN
export SECURITY_LEVEL
export USE_SECURE_COMMUNICATION
export SHARED_SECRET_FILE
export SECURITY_DIR
export DEFAULT_KEYSTORE_PATH
export KEYSTORE_PASSWORD
export MDCE_ALLOW_GLOBAL_PASSWORDLESS_LOGON
export ALLOW_CLIENT_PASSWORD_CACHE
export ADMIN_USER
export ALLOWED_USERS
