@echo off
REM ********************************************************
REM
REM embedded_target_download.bat
REM
REM Batch file to launch the embedded_target_download 
REM GUI from a Windows command prompt.
REM
REM ********************************************************
REM 
if "%1"=="-help" goto HELP
cls
echo.
echo ------------------------------------------------------
echo Launching Embedded Target Download (Standalone)
echo.
echo (run "embedded_target_download -help" for help)
echo ------------------------------------------------------
echo.

setlocal
REM Set DOWNLOAD_WORK_DIR to the directory where your applications are saved to.
set DOWNLOAD_WORK_DIR="d:\work_dirs\Aetargets\work"
echo Work directory is set to = %DOWNLOAD_WORK_DIR%
java -cp common.jar;util.jar;services.jar;jmi.jar;beans.jar;mwt.jar;mwswing.jar;RXTXcomm.jar;ecoder.jar com.mathworks.toolbox.ecoder.canlib.CanDownload.StandaloneMPC555Control %DOWNLOAD_WORK_DIR% "./" 
goto EXIT

:HELP
cls
echo -----------------------------------------------------
echo.
echo Embedded Target Download (Standalone) Help
echo.
echo.
echo DOWNLOAD_WORK_DIR:
echo.     
echo The location used to look for application files to 
echo download. You can edit this batch file 
echo (embedded_target_download.bat) to set your own location.
echo.
echo Requirements:
echo.
echo Java Virtual Machine (JVM):
echo     This utility is written using Java, and requires a JVM
echo     in order to run.   Please install a Java Runtime Environment
echo     on your system and ensure that the path to the Java
echo     Interpreter is added to the system path, so that java.exe can
echo     be executed from the command line. (http://java.sun.com)
echo.
echo For downloading over CAN:
echo.
echo Vector-Informatik CAN Programming DLL (vcand32.dll): 
echo     This file is available from Vector-Informatik, and 
echo     must be somewhere on the system path (includes current dir)
echo     (http://www.vector-informatik.de/english)
echo.
echo Vector-Informatik CAN Drivers:
echo     Hardware drivers for your CAN hardware must be installed on the system.
echo     These drivers are available from Vector-Informatik
echo     (http://www.vector-informatik.de/english)
echo.
echo --------------------------------------------------------------------------
goto done


:EXIT 
echo.  
echo ---------------------------------
echo Finished Embedded Target Download 
echo ---------------------------------

:done
