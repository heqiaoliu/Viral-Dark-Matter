#!/bin/sh
# Ensure that under SGE, we're in /bin/sh too:
#$ -S /bin/sh
# Pass through the right environment:
#$ -v MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_CMR,MDCE_MATLAB_EXE,MDCE_MATLAB_ARGS,MDCE_TOTAL_TASKS,MDCE_DEBUG
# The previous line ensures that all required environment variables are
# forwarded from the client MATLAB session through the scheduler to the cluster.
# 
# This script uses the following environment variables set by the code in the submit function:
# MDCE_CMR            - the value of ClusterMatlabRoot (may be empty)
# MDCE_MATLAB_EXE     - the MATLAB executable to use
# MDCE_MATLAB_ARGS    - the MATLAB args to use
#
# The following environment variables are forwarded through mpiexec:
# MDCE_DECODE_FUNCTION     - the decode function to use
# MDCE_STORAGE_LOCATION    - used by decode function 
# MDCE_STORAGE_CONSTRUCTOR - used by decode function 
# MDCE_JOB_LOCATION        - used by decode function 

# Copyright 2006-2008 The MathWorks, Inc.
# $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:05:36 $

# Create full paths to mw_smpd/mw_mpiexec if needed
FULL_SMPD=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_smpd
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec
SMPD_LAUNCHED_HOSTS=""
MPIEXEC_CODE=0

# Assert that we can read $TMPDIR/machines
if [ ! -r ${TMPDIR}/machines ]; then
    echo "Couldn't read ${TMPDIR}/machines" >&2
    exit 1
fi

# Work out where we need to launch SMPDs given our hosts file - defines
# SMPD_HOSTS
chooseSmpdHosts() {
    SMPD_HOSTS=`uniq $TMPDIR/machines`
}

# Work out which port to use for SMPD
chooseSmpdPort() {
    # Choose unique port for SMPD to run on. Derive from SGE's JOB_ID
    SMPD_PORT=`expr $JOB_ID % 10000 + 20000`
}

# Work out how many processes to launch - set MACHINE_ARG
chooseMachineArg() {
    
    MACHINE_ARG="-n ${NSLOTS} -machinefile ${TMPDIR}/machines"
}

# Now that we have launched the SMPDs, we must install a trap to ensure that
# they are closed either in the case of normal exit, or job cancellation:
# Default value of the return code
cleanupAndExit() {
    echo ""
    echo "Stopping SMPD on ${SMPD_LAUNCHED_HOSTS} ..."
    for host in ${SMPD_LAUNCHED_HOSTS}
    do
        echo ssh $host \"${FULL_SMPD}\" -shutdown -phrase MATLAB -port ${SMPD_PORT}
        ssh $host \"${FULL_SMPD}\" -shutdown -phrase MATLAB -port ${SMPD_PORT}
    done
    echo "Exiting with code: ${MPIEXEC_CODE}"
    exit ${MPIEXEC_CODE}
}

# Use ssh to launch the SMPD daemons on each processor
launchSmpds() {
    # Launch the SMPD processes on all hosts using SSH
    echo "Starting SMPD on ${SMPD_HOSTS} ..."
    for host in ${SMPD_HOSTS}
      do
      # This script assumes that SSH is set up to work without passwords between
      # all nodes on the cluster
      echo ssh $host \"${FULL_SMPD}\" -s -phrase MATLAB -port ${SMPD_PORT}
      ssh $host \"${FULL_SMPD}\" -s -phrase MATLAB -port ${SMPD_PORT}
      ssh_return=${?}
      if [ ${ssh_return} -ne 0 ]
          then
          echo "Launching smpd failed for node: ${host}"
          exit 1
      else
          SMPD_LAUNCHED_HOSTS="${SMPD_LAUNCHED_HOSTS} ${host}"
      fi
    done
    echo "All SMPDs launched"
}

runMpiexec() {
    # As a debug stage: echo the command line...
    echo \"${FULL_MPIEXEC}\" -phrase MATLAB -port ${SMPD_PORT} \
        -l ${MACHINE_ARG} -genvlist \
        MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION \
        \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}
    
    # ...and then execute it
    eval \"${FULL_MPIEXEC}\" -phrase MATLAB -port ${SMPD_PORT} \
        -l ${MACHINE_ARG} -genvlist \
        MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION \
        \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}
    MPIEXEC_CODE=${?}
}

# Define the order in which we execute the stages defined above
MAIN() {
    trap "cleanupAndExit" 0 1 2 15
    chooseSmpdHosts
    chooseSmpdPort
    launchSmpds
    chooseMachineArg
    runMpiexec
    exit ${MPIEXEC_CODE}
}

# Call the MAIN loop
MAIN
