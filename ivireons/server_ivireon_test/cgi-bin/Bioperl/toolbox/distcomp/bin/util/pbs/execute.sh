echo "Executing: ${MDCE_MATLAB_EXE} ${MDCE_MATLAB_ARGS}"
<PBS_ATTACH> "${MDCE_MATLAB_EXE}" ${MDCE_MATLAB_ARGS}
echo "MATLAB exited with code: $?"
