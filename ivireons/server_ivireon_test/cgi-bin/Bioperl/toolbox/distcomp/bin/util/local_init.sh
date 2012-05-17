#! /bin/sh

# Copyright 2004-2010 The MathWorks, Inc.

# Do not modify anything beyond this point
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# function that returns true (0) if on a mac and false otherwise
#-----------------------------------------------------------------------------
ismac() {
    test \( "$ARCH" = "maci" -o "$ARCH" = "maci64" \)
}

#-----------------------------------------------------------------------------
# function that returns true (0) if on solaris and false otherwise
#-----------------------------------------------------------------------------
issol() {
    test \( "$ARCH" = "sol2" -o "$ARCH" = "sol64" \)
}

#-----------------------------------------------------------------------------
# Local Echo to allow uses of these functions to turn off
# echo to the command window. This is useful for the system 5
# startup scripts
#-----------------------------------------------------------------------------
localecho() {
    if [ "$QUIET" = "false" ]
    then
        echo "$1"
    fi
}

#-----------------------------------------------------------------------------
# Set the pid from the PIDFILE.
# If the value in the PIDFILE is stale, delete the file.
#-----------------------------------------------------------------------------
getpid() {
    if [ -f "$PIDFILE" ]
    then
        if [ -r "$PIDFILE" ]
        then
            pid=`cat "$PIDFILE"`
            if [ "X$pid" != "X" ]
            then
                # Verify that a process with this pid is still running.
                pid=`$PSEXE -p $pid | grep $pid | grep -v grep | awk '{print $1}' | tail -1`
                if [ "X$pid" = "X" ]
                then
                    # This is a stale pid file.
                    rm -f "$PIDFILE"
                    localecho "Removed stale pid file: $PIDFILE"
                fi
            fi
        else
            localecho "Cannot read $PIDFILE."
            exit 1
        fi
    fi
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
msgLookAtLogFile() {
    if [ -f "$MDCE_SERVICE_LOG_FILE" ]; then
        localecho ""
        localecho "Note: If you expected the $APP_LONG_NAME to be running, look at"
        localecho "  $MDCE_SERVICE_LOG_FILE"
        localecho "for information about why it stopped."
    fi
}

#-----------------------------------------------------------------------------
# Set the pid to the value of found by ps.
# If the pid is not present in ps's output, delete the PIDFILE.
#-----------------------------------------------------------------------------
testpid() {
    pid=`$PSEXE -p $pid | grep $pid | grep -v grep | awk '{print $1}' | tail -1`
    if [ "X$pid" = "X" ]
    then
        # Process is gone so remove the pid file.
        rm -f "$PIDFILE"
    fi
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
echoReadTheManual() {
    localecho "See the MATLAB Distributed Computing Server installation "
    localecho "instructions at http://www.mathworks.com/distconfig"
}


#-----------------------------------------------------------------------------
# Determine if mdce is running on a mac and should use launchd.
# If so, set variables to support it.
# Check the state and commandline arguments to make sure the command can work.
# If the system is in an undecipherable state, then report and exit.
#-----------------------------------------------------------------------------
setupForLaunchd() {
    getpid
    
    # If a user has set up their mac to start automatically, by putting
    # the $MDCELAUNCHDLABEL.plist file in /Library/LaunchDaemons then
    # this script assumes that mdce should be controlled via launchd
    # and USINGLAUNCHD will be 1. Otherwise, 0.
    USINGLAUNCHD=0
    
    # If 'launchctl list' shows MDCELAUNCHDLABEL, this script infers that
    # launchd is controlling mdce. In the nominal cases, launchctl will list
    # MDCELAUNCHDLABEL and mdced will be live -or- launchctl will not list 
    # MDCELAUNCHDLABEL and mdced will not be a live process. It is possible
    # for launctl to list MDCELAUNCHDLABEL and for the process to be dead.
    # When this script detects that case, it will call 
    # launchctl remove MDCELAUNCHDLABEL from 
    MDCEFOUNDINLAUNCHD=0
    
    # If this script is run on a mac, launchd is available.
    if ismac ; then
        # the label for mdce in launchd
        MDCELAUNCHDLABEL="com.mathworks.mdce"
        # file that implies that mdce should use launchd
        PLISTFILE="/Library/LaunchDaemons/$MDCELAUNCHDLABEL.plist"
        # mdce command location
        MDCECOMMAND="$BASE/mdce"
        # grep expression to find the label
        LABELREGULAREXPRESSION=`echo "$MDCELAUNCHDLABEL" | sed 's/\./\\\\./g'`
        # If the .plist is in place
        if [ -f $PLISTFILE ];
        then
            # Control mdce via launchd
            USINGLAUNCHD=1
            # Look for com.mathworks.mdce in launchctl list.
            # (No need to use square brackets to test vs. $?. 
            #  grep's exit value is fine.) 
            if ( launchctl list | grep "$LABELREGULAREXPRESSION" > /dev/null )
            then
                MDCEFOUNDINLAUNCHD=1
            else
                if ( launchctl list | grep mdced > /dev/null )
                then
                    localecho "launchctl lists mdced, but not $MDCELAUNCHDLABEL ." 
                    localecho "This usually indicates that a different user "
                    localecho "added mdce to launchd. Check the .plist to learn"
                    localecho "the user, or try sudo mdce."
                    exit 1
                fi
            fi
        fi
    fi
    # Check some other illegal states. Exit if any are found
    # if not using launchd
    if [ "$USINGLAUNCHD" = 0 ];
    then
        # if someone used startasld
        if [ "$ACTION" = "startasld" ];
        then
            localecho "Only calls from within launchd should use the startasld command."
            localecho "Never use startasld on the command line ."
            localecho "launchd is supported only on Mac OSX. "
            echoReadTheManual
            exit 1
        fi
    else 
        # if using launchd and launchd lists mdce
        if [ "$MDCEFOUNDINLAUNCHD" = 1 ];
        then
            # if the action is not startld
            if [ ! "$ACTION" = "startasld" ];
            then
            # make sure the process is there
                if [ -z "$pid" ];
                then 
                    launchctl remove $MDCELAUNCHDLABEL
                    localecho "launchd lists mdce as one of the daemons it controls, but " 
                    localecho "the mdce process is not running. "
                    localecho "launchd may have continued to attept to start mdce. "
                    localecho "This script has called launchctl remove $MDCELAUNCHDLABEL ."
                    localecho "launchd's entries in /var/log/system.log may contain "
                    localecho "helpful information. "
                    echoReadTheManual
                fi
            fi
        fi
    fi
}

#-----------------------------------------------------------------------------
#Test if someone has used the clean flag. If so, clean up.
#-----------------------------------------------------------------------------
cleanIfNeeded() {
    #if someone used the -clean flag
    if [ "$DELETEFILES" = 1 ] ; then
        #delete the mdced files
        . "$UTILBASE/deleteServiceFiles.sh"
        deleteAllServiceFilesOrExit;
    fi
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
console() {
    localecho "Running the $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        cleanIfNeeded
        exec $CMDNICE $WRAPPER_CMD $WRAPPER_CONF wrapper.pidfile="$PIDFILE"
    else
        localecho "The $APP_LONG_NAME is already running."
        localecho "Use nodestatus to obtain more information."
        exit 1
    fi
}

#-----------------------------------------------------------------------------
# Make sure mdced is not already running and that the pid file is writable.
#-----------------------------------------------------------------------------
beforeStart() {
    getpid
    if [ -n "$pid" ]; then
        localecho "The $APP_LONG_NAME is already running."
        localecho "Use nodestatus to obtain more information."
        exit 1
    fi

    # Better check to see if we can actually write a pidfile
    touch "$PIDFILE" > /dev/null 2>&1 && rm -f "$PIDFILE"
    if  [ $? -ne 0 ]; then
        localecho "Unable to write pid file ($PIDFILE)"
        exit 1
    fi
}



#-----------------------------------------------------------------------------
# Start by using launchctl submit
#-----------------------------------------------------------------------------
startViaLaunchd() {
    # Use launchd submit start mdce inside launchd
    localecho "Starting the $APP_LONG_NAME using launchctl."
    # launchctl submit ignores the existing plist file.
    eval launchctl submit -l $MDCELAUNCHDLABEL -- $MDCECOMMAND startasld $NONACTIONARGS
}

#-----------------------------------------------------------------------------
# Start by using eval or sudo to start a background process.
#-----------------------------------------------------------------------------
startViaEval() {
    localecho "Starting the $APP_LONG_NAME in the background."
    # Start mdced
    if [ -z "$MDCEUSER" ]; then
        # Execute the wrapper command in the background. This ensures that the  
        # PID of the last spawned process ($!) will be the correct PID of the
        # wrapper process
        eval "$CMDNICE $WRAPPER_CMD $WRAPPER_CONF > /dev/null 2>&1 &"
    else
        # Execute the wrapper command in the background as the MDCE user
        sudo -u $MDCEUSER $CMDNICE $WRAPPER_CMD $WRAPPER_CONF > /dev/null 2>&1 &
    fi
    # Get the PID of the just executed command
    PIDVAL=$!
    # If the daemon call succeeds then get a lock on this
    # subsystem and write out the pid file
    if [ $PIDVAL -ne 0 ]; then
        echo $PIDVAL > "$PIDFILE"
    fi
}

#-----------------------------------------------------------------------------
# Start by using exec or exec sudo.
#-----------------------------------------------------------------------------
startViaExec() {
    # get the pid of this process
    PIDVAL=$$
    # write out the pid file
    echo $PIDVAL > "$PIDFILE"
    
    # Exec the wrapper command in the foreground. This causes the  
    # PID of this process to be the correct PID of the wrapper process
    if [ -z "$MDCEUSER" ]; then
        # As this user
        exec $CMDNICE $WRAPPER_CMD $WRAPPER_CONF > /dev/null 2>&1
    else
        # As the MDCE user
        exec sudo -u $MDCEUSER $CMDNICE $WRAPPER_CMD $WRAPPER_CONF > /dev/null 2>&1
    fi
}

#-----------------------------------------------------------------------------
# Start the process under launchd.
# If launchctl and launchd are being used to control mdced then
# the only two viable states are
# 1) mdce is live and will be listed in launchctl list.
# 2) mdce is not live and will not be listed.
#
# To achieve this end, start uses launchctl submit 
# and stop uses launchctl remove to control mdced.
#
# launchd in turn uses this function, mdce startasld to start mdced,
# and exec to keep the process id of this process.
#-----------------------------------------------------------------------------
startUnderLaunchd() {    
    # Make sure this is ONLY called on a mac
    if ! ismac ; then
        localecho "The -launchd flag is only applicable to running mdce on "
        localecho "the mac platform and cannot be used on any other unix platform."
        echoReadTheManual
        exit 1
    fi

    beforeStart
    # make sure the process is not there already
    if [ -n "$pid" ];
    then
        localecho "launchd is attempting to start mdced, but mdced "
        localecho "appears to already be running with a pid of $pid ." 
        echoReadTheManual
        exit 1
    fi

    # Will only clean if launched via a .plist with a -clean argument
    cleanIfNeeded
    startViaExec
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
start() {
    beforeStart
    cleanIfNeeded
    
    if ismac && [ "$USINGLAUNCHD" = 1 ] ; then  
        # If we are on a mac and we think we are using launchd then do
        startViaLaunchd
    else
        # then use the background eval approach
        startViaEval
    fi
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
status() {
    getpid
    if [ "X$pid" = "X" ]
    then
        localecho "The $APP_LONG_NAME is stopped."
        msgLookAtLogFile;
    else
        localecho "The $APP_LONG_NAME is running with PID $pid."
        localecho "Use nodestatus to obtain more information."
    fi
}

#-----------------------------------------------------------------------------
# We can not predict how long it will take for the wrapper to
#  actually stop as it depends on settings in wrapper.conf.
#  Loop until it does, or 300 seconds pass.
#-----------------------------------------------------------------------------
waitForPIDToEnd() {
    CNT=0
    TOTCNT=0
    while [ "X$pid" != "X" ]
    do
        # Loop for up to 5 minutes
        if [ "$TOTCNT" -lt "300" ]
        then
            if [ "$CNT" -lt "5" ]
            then
                CNT=`expr $CNT + 1`
            else
                localecho "Waiting for $APP_LONG_NAME to exit..."
                CNT=0
            fi
            TOTCNT=`expr $TOTCNT + 1`

            sleep 1

            testpid
        else
            pid=
        fi
    done
}

#-----------------------------------------------------------------------------
# use launchctl remove to stop mdce.
#-----------------------------------------------------------------------------
stopViaLaunchd() {
    # If mdce is in launchd
    if [ "$MDCEFOUNDINLAUNCHD" = 1 ]; then
        # Stop mdce by removing it from launchd
        # launchctl remove will send the SIGTERM 
        # to the mdce start process
        eval launchctl remove $MDCELAUNCHDLABEL
        # launchctl remove always returns immediately, so always wait
        # for $pid to finish
        savepid=$pid
        waitForPIDToEnd
        pid=$savepid
    else
        localecho "mdced is running as process $pid and the file "
        localecho "$PLISTFILE exists. "
        localecho "However, launchctl list did not list" 
        localecho "$MDCELAUNCHDLABEL . Move $PLISTFILE "
        localecho "out of /Library/LaunchDaemons and "
        localecho "try './mdce stop' again to stop the process."
        echoReadTheManual
        exit 1
    fi
}

#-----------------------------------------------------------------------------
# Use kill to stop mdce.
#-----------------------------------------------------------------------------
stopViaEval() {
    # Either mdce is not in launchd or this has been called by launchd
    # Stop the process
    if [ -z "$MDCEUSER" ]; then
        kill $pid
    else
        sudo -u $MDCEUSER kill $pid
    fi
    if [ $? -ne 0 ]
    then
        # An explanation for the failure should have been given
        localecho "Unable to stop $APP_LONG_NAME."
        exit 1
    fi

    savepid=$pid
    # Give mdced some time to finish and clean up.
    waitForPIDToEnd
    pid=$savepid

    testpid
    if [ "X$pid" != "X" ]
    then
        localecho "Timed out waiting for $APP_LONG_NAME to exit."
        localecho "  Attempting a forced exit..."
        if [ -z "$MDCEUSER" ]; then
            kill -9 $pid
        else
            sudo -u $MDCEUSER kill -9 $pid
        fi
    fi

    pid=$savepid
    testpid
    if [ "X$pid" != "X" ]
    then
        localecho "Failed to stop $APP_LONG_NAME."
        exit 1
    else
        localecho "Stopped $APP_LONG_NAME."
    fi
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
stopit() {
    localecho "Stopping the $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        localecho "The $APP_LONG_NAME was not running."
        msgLookAtLogFile;
        return 1
    fi
    
    if ismac && [ "$USINGLAUNCHD" = 1 ] ; then  
        # If we are on a mac and are using launchd then do
        stopViaLaunchd
    else
        # otherwise fall back on the normal unix approach
        stopViaEval
    fi
    cleanIfNeeded
} # End of stopit.

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
dump() {
    localecho "Dumping $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        localecho "$APP_LONG_NAME was not running."
    else
        kill -3 $pid

        if [ $? -ne 0 ]
        then
            localecho "Failed to dump $APP_LONG_NAME."
            exit 1
        else
            localecho "Dumped $APP_LONG_NAME."
        fi
    fi
} # End of dump.

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
version() {
    $JRECMD -classpath "$DISTCOMP_ONLY_CLASSPATH" \
        com.mathworks.toolbox.distcomp.util.Version
    echo
}

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
info() {
    echo "VERSION=`version`"
    echo "BASEPORT=$BASE_PORT"
    echo "CHECKPOINTDIR_CONTENTS=`getCheckpointContents`"
    echo "MDCED_PIDS=`getMdcedPids`"
    echo "HOSTNAME=$HOSTNAME"
    echo "CHECKPOINTBASE=$CHECKPOINTBASE"
}

# Print a list of whitespace separated log directories in the checkpoint dir.
# The following shell command finds all directories in CHECKPOINTBASE with
# names ending with _log and prints them on one line.
getCheckpointContents() {
    find $CHECKPOINTBASE -maxdepth 1 -mindepth 1 -type d -name '*_log' -exec basename {} \; 2> /dev/null | awk '{printf("%s ", $1)}'
}

# Print a list of whitespace separated pids of all mdced processes.
# The following shell command finds the pids of all running mdce daemons and
# prints them on one line.
getMdcedPids() {
    ps cax | grep mdced | awk '{printf("%s ", $1)}'
}
#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
usage()
{
    echo
    echo "mdce:           Start the base service associated with the MATLAB Distributed"
    echo "                Computing Server.  The mdce service ensures that all other"
    echo "                processes are running and that it is possible to communicate"
    echo "                with them."
    echo "                Once the mdce service is running, you can use the nodestatus"
    echo "                command to obtain information about the mdce service and all the"
    echo "                processes it maintains."
    echo
    echo "Usage: mdce [ start | stop | restart | status | console ]"
    echo "            [ -clean ] [ -mdcedef mdce_defaults_file ] [ -version ] [ -help ]"
    echo
    echo "start           Start the mdce service. This creates the required logging"
    echo "                and checkpointing directories, and then starts the service"
    echo "                as specified in the mdce defaults file."
    echo
    echo "stop            Stop running the mdce service. This automatically stops all"
    echo "                job managers and workers on the computer, but leaves their"
    echo "                checkpoint information intact so that they will start again "
    echo "                when the mdce service is started again."
    echo
    echo "restart         Equivalent to doing stop, then start."
    echo
    echo "status          Report the status of the mdce service.  Indicate if it"
    echo "                is running and with what PID."
    echo "                Use nodestatus to obtain more detailed information about "
    echo "                the mdce service."
    echo
    echo "console         Start the mdce service as a process in the current "
    echo "                terminal rather than as a service running in the "
    echo "                background."
    echo
    echo "-clean          Perform a complete cleanup of all service checkpointing and "
    echo "                log files before starting the service, or after stopping it."
    echo "                Note: This will delete all information about any job managers"
    echo "                or workers this service has ever maintained."  
    echo
    echo "-mdcedef        Specify an alternative mdce defaults file instead of the one"
    echo "                found in MATLABROOT/toolbox/distcomp/bin. "
    echo
    echo "-version        Print version information to standard output and exit."
    echo
    echo "-help           Print this help information."
    echo
    echo "See also:       nodestatus, startjobmanager, stopjobmanager, startworker, and"
    echo "                stopworker."
    echo
} # End of usage.

#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
runCommandAndExit() {
    
    # Build the nice clause
    if [ "X$PRIORITY" = "X" ]
        then
        CMDNICE=""
    else
        CMDNICE="nice -$PRIORITY"
    fi

    # It appears that Solaris makes some strange changes to the nice level of
    #
    if issol ; then
        if [ -z "$CMDNICE" ]; then
            CMDNICE="nice -n 1"
        fi
    fi

    # Ensure the pid is defined
    pid=""
    
    QUIET="false"
    ACTION="$1"
    DELETEFILES="$2"

    # Set internal variables for MacOSX running launchd
    if ismac ; then
        setupForLaunchd
    fi  

    case "$ACTION" in

        'console')
            console
            ;;

        'start')
            start
            ;;
        'startasld')
            startUnderLaunchd
            ;;

        'stop')
            stopit
            ;;

        'status')
            status
            ;;

        'restart')
            stopit
            start
            ;;

        'dump')
            dump
            ;;

        'version')
            version
            ;;

        'info')
            info
            ;;

        *)
            usage
            exit 1
            ;;
    esac

    exit 0
} # End of RunCommandAndExit
