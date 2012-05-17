#!/bin/sh
# This script is designed to be called by sshParallelSubmitFcn
#
# This script uses the following environment variables set by the submit function:
# MDCE_CMR            - the value of ClusterMatlabRoot (may be empty)
# MDCE_MATLAB_EXE     - the MATLAB executable to use
# MDCE_MATLAB_ARGS    - the MATLAB args to use
# MDCE_SMPD_PORT      - the port to use for SMPD
# MDCE_HOSTS_FILE     - the hosts file to use
# MDCE_NUM_PROCS      - the number of processes to launch
#
# The following environment variables are forwarded through mpiexec:
# MDCE_DECODE_FUNCTION     - the decode function to use
# MDCE_STORAGE_LOCATION    - used by decode function 
# MDCE_STORAGE_CONSTRUCTOR - used by decode function 
# MDCE_JOB_LOCATION        - used by decode function 

# Copyright 2006-2010 The MathWorks, Inc.
# $Revision: 1.1.8.3 $   $Date: 2010/03/22 03:42:22 $

# Create full paths to mw_smpd/mw_mpiexec if needed
FULL_SMPD=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_smpd
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec
SMPD_LAUNCHED_HOSTS=""
MPIEXEC_CODE=0

# Work out where we need to launch SMPDs given our hosts file - defines
# SMPD_HOSTS
chooseSmpdHosts() {
    # Check that we can read the hosts file
    if [ -f $MDCE_HOSTS_FILE ]
        then
        echo "Hosts will be chosen from $MDCE_HOSTS_FILE"
    else
        echo "Cannot read hosts file $MDCE_HOSTS_FILE"
        exit 1
    fi
    # We rely on the fact that "head" will not complain if there are fewer lines
    # in $MDCE_HOSTS_FILE than specified by $MDCE_NUM_PROCS. Also, we rely on
    # the fact that mpiexec will re-use entries from $MDCE_HOSTS_FILE.
    SMPD_HOSTS=`head -n $MDCE_NUM_PROCS $MDCE_HOSTS_FILE | uniq | tr '\n' ' '`
}

# Work out which port to use for SMPD
chooseSmpdPort() {
    SMPD_PORT=${MDCE_SMPD_PORT}
}

# Work out how many processes to launch - set NUM_PROCS
chooseMachineArg() {
    MACHINE_ARG="-n ${MDCE_NUM_PROCS} -machinefile ${MDCE_HOSTS_FILE}"
}

# This cleanup function is called in the case of normal or abnormal exit.
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