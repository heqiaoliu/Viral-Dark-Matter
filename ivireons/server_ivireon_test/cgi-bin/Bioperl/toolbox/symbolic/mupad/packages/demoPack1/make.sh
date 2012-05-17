#!/bin/sh -f
#
# This script contains all things to be done for a package build 
# apart from building the documentation (see makeDoc.sh).
# It builds a module and a Tar library of the source code.  
# Extend (or strip down) this script to your needs.


#  make sure that mupkern and mmg are in your path, when you call this script

if [ $# -eq 1 ] ; then 
    if [ "$1" = "tarlib" ] ; then 
        # the name of the package, needed below
        PACKNAME=`basename \`pwd\``

        # make a Tar-lib from the package source
        mkdir -p TMP/
        cp -r lib TMP/
        # we do not want to see .svn or TEST directories in the Tar lib
        (cd TMP/lib/; rm -rf .svn */.svn */*/.svn */TEST */*/TEST)
        (cd TMP/lib; tar cf ../../lib.tar *)
        rm -rf TMP/
        #  call the kernel once to generate the toc-file for the lib
        /bin/echo -e "package(\"$PACKNAME\");\nquit;\n" |  mupkern -p ..
    else
        echo "Unknown parameter: $1"
        echo
        echo "Usage:  make.sh [ tarlib ]"
    fi
else
    # build the module(s)
    make -C src/modules archclean
    make -C src/modules
fi
