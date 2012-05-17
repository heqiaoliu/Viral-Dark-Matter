#!/bin/sh
#=======================================================================
# Functions:  Required by call to arch.sh
#   check_archlist ()
#=======================================================================

# Copyright 2004-2010 The MathWorks, Inc.

 check_archlist () {
         return 0
 }

 # Resolve the location of the 'ps' command
 PSEXE="/usr/bin/ps"
 if [ ! -x $PSEXE ]
 then
     PSEXE="/bin/ps"
     if [ ! -x $PSEXE ]
     then
         echo "Unable to locate 'ps'."
         exit 1
     fi
fi
# All scripts should call this function after they have changed to the
# MATLABROOT/toolbox/distcomp/bin directory
# Reinitialise the BASE variable to pick up any '..' type elements in the call
BASE=`pwd`
# Define the MATBASE (MATLABROOT) directory
MATBASE=`echo $BASE | sed -e 's;/toolbox/distcomp/bin;;g'`
MDCEBASE="$MATBASE/toolbox/distcomp"
CONFIGBASE="$MDCEBASE/config"
UTILBASE="$MDCEBASE/bin/util"

JARBASE="$MATBASE/java/jar/toolbox"
JAREXTBASE="$MATBASE/java/jarext/distcomp"
JINILIB="$JAREXTBASE/jini2/lib"
# The classpath that all the start and stop scripts should use.
REMOTE_COMMAND_CLASSPATH="$JINILIB/start.jar:$JINILIB/destroy.jar:$JINILIB/phoenix.jar:$JINILIB/reggie.jar:$JINILIB/jini-ext.jar:$JARBASE/distcomp.jar"
DISTCOMP_ONLY_CLASSPATH="$JARBASE/distcomp.jar"
# Call arch.sh to define the $ARCH variable - this is the same as is
# used in setmlenv
ARCH=""
. "$MATBASE/bin/util/arch.sh"
