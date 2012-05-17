#!/bin/sh

#  exec_redirect: helper for mpiexec to allow command output redirection
#  regardless of the user's choice of shell

#  Copyright 2000-2006 The MathWorks, Inc.
#  $Revision: 1.1.10.4 $    $Date: 2009/02/06 14:16:59 $ 

# Ensure that our output log file isn't too large. Limit it to 10GB for a system
# with 1024-byte blocks. On systems with 512-byte blocks, this limit will be
# equivalent to 5GB.  If an application attempts to create a log file larger
# than this, then it will be terminated. This limit is in place to prevent a
# runaway process from completely filling disk space. 
#
# If you wish to allow a larger log file limit, simply remove or modify this
# line.
ulimit -f 10000000

# Limit the core size to zero, since we are not interested in
# core dumps produced by mpiexec.
ulimit -c 0

# extract the file that we are going to send all output to
fname=$1;
shift

# extract the name of the mpiexec executable
mpiexec=$1
shift

# Where is this script located - doesn't matter if it's a relative path or
# linked - we need this for the passwdmsg.txt file
script_dir=`dirname $0`

# Evaluate the command line with stdout and stderr redirection. 

case $MDCE_INPUT_REDIRECT in
    null)
        "$mpiexec" "${@}" >> "$fname" 2>&1 < /dev/null &
        echo $!
        ;;
    yes)
        # The MPIEXEC scheduler has determined that an input redirection is
        # required. This always happens on MAC (to prevent the mpiexec process
        # from erroring out when it tries to set attributes of stdin), and on
        # other platforms if the WorkerMachineOsType is set to 'pc' (to prevent
        # the mpiexec process from repeatedly prompting for credentials if none
        # are supplied in the SubmitArguments).
        "$mpiexec" "${@}" >> "$fname" 2>&1 < ${script_dir}/passwdmsg.txt &
        echo $!
        ;;
    *)
        # Default execution: no input redirection.
        "$mpiexec" "${@}" >> "$fname" 2>&1 &
        echo $!
        ;;
esac
