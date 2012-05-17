#!/bin/sh
# 
# This wrapper script is used by the lsfscheduler to perform the following tasks:
# 1. Launch process manager daemons on the execution hosts, using a unique port
#    based on LSB_JOBID
# 2. Call mpiexec to launch MATLAB on the execution hosts
# 3. Clean up the process managers on the execution hosts
#
# The lsfscheduler object in MATLAB creates the environment variable MDCE_CMR
#
# The required environment variables will automatically be forwarded to the
# MATLAB processes. This occurs because lsgrun will forward the environment to
# the nodes where SMPD is launched, and then the MATLABs launched using mpiexec
# will inherit their environment from the SMPD process. If you adapt this
# script, you must ensure that the following environment variables are forwarded
# through to the MATLABs:
#
# - MDCE_DECODE_FUNCTION
# - MDCE_STORAGE_LOCATION
# - MDCE_STORAGE_CONSTRUCTOR
# - MDCE_JOB_LOCATION
# - LSB_JOBID
#
# All MPICH2 builds of MPIEXEC support a "-genvlist" argument, in which you may
# simply specify a comma-separated list of environment variables to forward.

# Copyright 2006-2009 The MathWorks, Inc.
# $Revision: 1.1.6.3 $   $Date: 2009/05/14 16:49:54 $

#
# This function is called with a single argument: a space-separated list of
# hosts on which to launch the process managers
# 
launchProcessManagers() {
    callSmpdOnHosts "$1" -s
}

#
# This function is called with a single argument: the list of process manager
# hosts
#
shutdownProcessManagers() {
    callSmpdOnHosts "$1" -shutdown
}

#
# This function is used to launch mpiexec. This will be called with a series of
# arguments to be forwarded to matlab. 
#
callMpiexec() {
    echo "$MPIEXEC" \
	-noprompt -l -exitcodes -phrase MATLAB_LSF -port ${SMPD_PORT} \
	-hosts ${NUM_PM_HOSTS} ${LSB_MCPU_HOSTS} ${MATLAB_CMD}
    if [ ${REDIRECT_MPIEXEC_STDIN} -eq 1 ]; then
	eval "$MPIEXEC" \
	    -noprompt -l -exitcodes -phrase MATLAB_LSF -port ${SMPD_PORT} \
	    -hosts ${NUM_PM_HOSTS} ${LSB_MCPU_HOSTS} ${MATLAB_CMD} < ${MPIEXEC_STDIN_FNAME}
    else
        # Redirect /dev/null into mpiexec to avoid maxing-out CPU usage.
	eval "$MPIEXEC" \
	    -noprompt -l -exitcodes -phrase MATLAB_LSF -port ${SMPD_PORT} \
	    -hosts ${NUM_PM_HOSTS} ${LSB_MCPU_HOSTS} ${MATLAB_CMD} < /dev/null
    fi

    MPIEXEC_EXIT_CODE=$?
    echo "mpiexec completed with exit code: ${MPIEXEC_EXIT_CODE}"
}

#
# This utility function chooses a port for the SMPD process manager. This can be
# customised to fit in with inter-worker firewalls.
#
chooseSmpdPort() {
    SMPD_PORT=`expr ${LSB_JOBID} % 10000 + 20000`
}

#
# This manipulates smpd everywhere. It uses the LSF utility "lsgrun" to call
# smpd on all hosts. The variable SMPD is used to choose which smpd executable
# to use.
#
callSmpdOnHosts() {
    hosts="$1"
    for host in $hosts
    do
        echo lsgrun -p -m ${host} "${SMPD}" $2 -phrase MATLAB_LSF -port ${SMPD_PORT}
        lsgrun -p -m ${host} "${SMPD}" $2  -phrase MATLAB_LSF -port ${SMPD_PORT}
        lsgrun_exit=$?
        if [ $lsgrun_exit -ne 0 ]
        then
            echo "*** an error occurred calling smpd $2 on ${host}, exiting"
            exit ${lsgrun_exit}
        fi
    done
}

#
# Extract the unique host names, and count them too
#
manipulateHosts() {
    isHost=1
    UNIQUE_PM_HOSTS=""
    NUM_PM_HOSTS=0
    for x in ${LSB_MCPU_HOSTS}
    do
        if [ ${isHost} -eq 1 ]
        then
            UNIQUE_PM_HOSTS="${UNIQUE_PM_HOSTS} ${x}"
            NUM_PM_HOSTS=`expr 1 + ${NUM_PM_HOSTS}`
        fi
        isHost=`expr 1 - ${isHost}`
    done
    
}


#
# This will be called in the event of either a bkill, or normal completion.
#
cleanupAndExit() {
    if [ ${REDIRECT_MPIEXEC_STDIN} -eq 1 ]; then
	rm -f ${MPIEXEC_STDIN_FNAME}
    fi
    shutdownProcessManagers "${UNIQUE_PM_HOSTS}"
    exit ${MPIEXEC_EXIT_CODE}
}

# This function decides whether we should redirect stdin for the
# mpiexec process. This is to work around problems only seen on MAC.
setupInputRedirect() {
    REDIRECT_MPIEXEC_STDIN=0
    if [ -f /bin/uname ]; then
	case "`/bin/uname`" in
	    Darwin)
		REDIRECT_MPIEXEC_STDIN=1
		;;
	esac
    elif [ -f /usr/bin/uname ]; then
	case "`/usr/bin/uname`" in
	    Darwin)
		REDIRECT_MPIEXEC_STDIN=1
		;;
	esac
    fi
    if [ ${REDIRECT_MPIEXEC_STDIN} -eq 1 ]; then
	MPIEXEC_STDIN_FNAME=/tmp/mpiexecstdin.${LSB_JOBID}
	echo "Dummy stdin for mpiexec on Mac" > ${MPIEXEC_STDIN_FNAME}
    fi
}

#
# If MDCE_CMR is set, use that to locate mw_smpd, mw_mpiexec and matlab - else
# assume on they're on the path
#
if [ "x${MDCE_CMR}" = "x" ] 
then
    SMPD=mw_smpd
    MPIEXEC=mw_mpiexec
    MATLAB_CMD="$*"
else
    SMPD="${MDCE_CMR}/bin/mw_smpd"
    MPIEXEC="${MDCE_CMR}/bin/mw_mpiexec"
    MATLAB_CMD="'${MDCE_CMR}'/bin/$*"
fi


# manipulate the LSB_MCPU_HOSTS variable - this function sets UNIQUE_PM_HOSTS
# and NUM_PM_HOSTS
manipulateHosts

# Choose whether we need to redirect stdin for mpiexec
setupInputRedirect

# Choose the SMPD port
chooseSmpdPort

#
# Install the trap early so that if bkill is called even while we're still
# setting up the process managers, we'll still try to shut them down.
#
trap cleanupAndExit 0 3 15

# Launch the process managers on UNIQUE_PM_HOSTS
launchProcessManagers "${UNIQUE_PM_HOSTS}"

MPIEXEC_EXIT_CODE=0
callMpiexec "${@}"
if [ ${MPIEXEC_EXIT_CODE} -eq 42 ]
then
    # Get here if user code errored out within MATLAB. Overwrite this to zero in
    # this case.
    echo "Overwriting MPIEXEC exit code from 42 to zero (42 indicates a user-code failure)"
    MPIEXEC_EXIT_CODE=0
fi
exit ${MPIEXEC_EXIT_CODE}
