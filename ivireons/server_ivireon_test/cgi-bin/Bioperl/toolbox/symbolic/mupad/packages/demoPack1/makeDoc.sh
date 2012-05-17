#!/bin/sh -f
#
# This script contains all things to be done for building the 
# documentation of a package.  
# Extend (or strip down) this script to your needs.

#  make sure that mupkern is in your path, when you call this script

# This is the path in the build environment.
[ -d ${MUPAD_DDKDIR:=`pwd`/../../../DOC} ] || (echo "No MuPAD DDK found"; exit 1)
export MUPAD_DDKDIR

# first cleanup
make -C src/doc MUPKERN=`which mupkern` clean

# build english documentation
make -C src/doc MUPKERN=`which mupkern` check
make -C src/doc MUPKERN=`which mupkern`

# build german documentation
#make -C src/doc MUPKERN=`which mupkern` LANGUAGE=de check
#make -C src/doc MUPKERN=`which mupkern` LANGUAGE=de
