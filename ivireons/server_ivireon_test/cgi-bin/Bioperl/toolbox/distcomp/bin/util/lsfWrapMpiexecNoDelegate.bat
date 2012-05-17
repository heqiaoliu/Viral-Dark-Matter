@echo off
REM This wrapper script is used by the lsfscheduler to call MPIEXEC to launch
REM MATLAB on the hosts allocated by LSF. We use "worker.bat" rather than
REM "matlab.bat" to ensure that the exit code from MATLAB is correctly
REM interpreted by MPIEXEC. 
REM
REM The following environment variables must be forwarded to the MATLABs:
REM - MDCE_DECODE_FUNCTION
REM - MDCE_STORAGE_LOCATION
REM - MDCE_STORAGE_CONSTRUCTOR
REM - MDCE_JOB_LOCATION
REM - LSB_JOBID
REM 
REM This is done using the "-genvlist" option to MPIEXEC. 
REM

REM Copyright 2006 The MathWorks, Inc.
REM $Revision: 1.1.6.2 $   $Date: 2006/06/27 22:40:22 $

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION 

if "x!MDCE_CMR!" == "x" (
  REM No ClusterMatlabRoot set, just call mw_mpiexec and matlab.bat directly.
  set MPIEXEC=mw_mpiexec
  set MATLAB_CMD=%*
) else (
  REM Use ClusterMatlabRoot to find mpiexec wrapper and matlab.bat
  set MPIEXEC="!MDCE_CMR!\bin\mw_mpiexec"
  set MATLAB_CMD="!MDCE_CMR!"\bin\%*
)

REM We need to count how many different hosts are in LSB_MCPU_HOSTS
set HOST_COUNT=0
call :countHosts %LSB_MCPU_HOSTS%

set GENVLIST=MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_DEBUG,LSB_JOBID

REM The actual call to MPIEXEC. Must use call for the mw_mpiexec.bat wrapper to
REM ensure that we can modify the return code from mpiexec.
echo !MPIEXEC! -noprompt -l -exitcodes -genvlist %GENVLIST% -hosts %HOST_COUNT% %LSB_MCPU_HOSTS% !MATLAB_CMD! 
call !MPIEXEC! -noprompt -l -exitcodes -genvlist %GENVLIST% -hosts %HOST_COUNT% %LSB_MCPU_HOSTS% !MATLAB_CMD! 

REM If MPIEXEC exited with code 42, this indicates a call to MPI_Abort from
REM within MATLAB. In this case, we do not wish LSF to think that the job failed
REM - the task error state within MATLAB will correctly indicate the job outcome.
set MPIEXEC_ERRORLEVEL=!ERRORLEVEL!
if %MPIEXEC_ERRORLEVEL% == 42 (
   echo Overwriting MPIEXEC exit code from 42 to zero (42 indicates a user-code failure)
   exit 0
) else (
   exit %MPIEXEC_ERRORLEVEL%
)

REM a simple loop to dig through LSB_MCPU_HOSTS to count how many unique hosts
REM are present in the list.
:countHosts
if (%1) == () goto :EOF
set /a HOST_COUNT=%HOST_COUNT% + 1
shift
shift
goto countHosts