#!/bin/sh
# This wrapper script is intended to support distributed execution.
# 
# This script uses the following environment variables set by the submit MATLAB code:
# MDCE_MATLAB_EXE     - the MATLAB executable to use
# MDCE_MATLAB_ARGS    - the MATLAB args to use
#

# Copyright 2010 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:11 $

echo "Executing: ${MDCE_MATLAB_EXE} ${MDCE_MATLAB_ARGS}"
exec "${MDCE_MATLAB_EXE}" ${MDCE_MATLAB_ARGS}