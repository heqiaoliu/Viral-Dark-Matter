#!/bin/sh
#PBS -v MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_TASK_ID,MDCE_MATLAB_EXE,MDCE_MATLAB_ARGS,MDCE_SCHED_TYPE,MDCE_DEBUG
<HEADERS>

# Copyright 2006-2007 The MathWorks, Inc.
# $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:38 $

# Check that our environment is intact
if [ ${MDCE_DECODE_FUNCTION:-X} = X ] ; then
    echo "Fatal error: environment variable MDCE_DECODE_FUNCTION is not set on the cluster"
    echo "This may happen if you have used '-v' in your scheduler SubmitArguments"
    echo "Please either use another means to transmit the information, or use '-V'"
    exit 1
fi

# Put ourselves in the TMPDIR for job execution - create one if none exists.
if [ ${TMPDIR:-X} = X ] ; then
    # Create a job directory
    TMPDIR=/tmp/${PBS_JOBID?"PBS_JOBID not defined!"}
    mkdir -p ${TMPDIR}
    export TMPDIR
    echo "Created directory: ${TMPDIR} on `hostname`"
    trap "cd /tmp ; rm -rf ${TMPDIR} ; echo Removed ${TMPDIR}" 0 1 2 15
fi
cd ${TMPDIR}
