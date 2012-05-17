#!/bin/sh
# This wrapper script is intended to be submitted to LSF to support parallel
# execution.
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

# Copyright 2006 The MathWorks, Inc.
# $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:04:40 $

# Create full paths to mw_smpd/mw_mpiexec if needed
FULL_SMPD=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_smpd
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec
SMPD_LAUNCHED_HOSTS=""
MPIEXEC_CODE=0

# manipulateHosts carries out the functions of both chooseSmpdHosts and
# chooseMachineArg - it is convenient to calculate both properties together
# since they both involve parsing the LSB_MCPU_HOSTS environment variable as set
# by LSF.
manipulateHosts() {
    # Make sure we don't execute the body of this function more than once
    if [ "${SMPD_HOSTS:-UNSET}" = "UNSET" ]
        then
        echo "Calculating SMPD_HOSTS and MACHINE_ARG"

        # LSB_MCPU_HOSTS is a series of hostnames and numbers, we need to pick
        # out just the names for the SMPD_HOSTS argument, and also count the
        # number of different hosts in use for mpiexec's "-hosts" argument. 
        isHost=1
        SMPD_HOSTS=""
        NUM_PM_HOSTS=0

        # Loop over every entry in LSB_MCPU_HOSTS
        for x in ${LSB_MCPU_HOSTS}
          do
          if [ ${isHost} -eq 1 ]
              # every other entry is a hostname
              then
              SMPD_HOSTS="${SMPD_HOSTS} ${x}"
              NUM_PM_HOSTS=`expr 1 + ${NUM_PM_HOSTS}`
          fi
          isHost=`expr 1 - ${isHost}`
        done
        MACHINE_ARG="-hosts ${NUM_PM_HOSTS} ${LSB_MCPU_HOSTS}"
    fi
}


# Work out where we need to launch SMPDs given our hosts file - defines
# SMPD_HOSTS
chooseSmpdHosts() {
    manipulateHosts
}

# Work out which port to use for SMPD
chooseSmpdPort() {
    # Use LSF's LSB_JOBID to calculate the port
    SMPD_PORT=`expr ${LSB_JOBID} % 10000 + 20000`
}

# Work out how many processes to launch - set MACHINE_ARG
chooseMachineArg() {
    manipulateHosts
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
