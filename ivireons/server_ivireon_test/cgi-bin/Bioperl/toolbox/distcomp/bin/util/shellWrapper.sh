#!/bin/sh
# Simple wrapper to re-write exit codes >= 127

# Copyright 2007 The MathWorks, Inc.
# $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:33 $

# execute arguments
"${@}"

# Re-write exit status
exitCode=$?
if [ ${exitCode} -gt 127 ] ; then
    exitCode=127
fi
exit ${exitCode}
