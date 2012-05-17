function [primaryLib, extras] = mpiLibConf
%mpiLibConf - return the location of an MPI implementation
%   [primaryLib, extras] = mpiLibConf returns the MPI implementation library
%   to be used by a parallel job. primaryLib must be the name of the shared
%   library file containing the MPI entry points. extras must be a cell
%   array of other library names required by the MPI library. The libraries
%   can be specified using full filenames if they are not available via the
%   PATH environment variable (on Windows), LD_LIBRARY_PATH (on Linux and
%   Solaris) or DYLD_LIBRARY_PATH (on Macintosh).
%
%   To supply an alternative MPI implementation, create a MATLAB file called
%   "mpiLibConf" and place it on the MATLAB path. The recommended location is
%   <matlabroot>/toolbox/distcomp/user.
%
%   Under all circumstances, the MPI library must support all MPI-1
%   functions. Additionally, the MPI library must support null arguments to
%   MPI_Init as defined in section 4.2 of the MPI-2 standard. The library
%   must also use an "mpi.h" header file which is fully compatible with
%   MPICH2.
%
%   When used with the DCT jobmanager, the MPI library must support the
%   following additional MPI-2 functions:
%   - MPI_Open_port
%   - MPI_Comm_accept
%   - MPI_Comm_connect
%
%   This product includes MD5 software developed by the OpenSSL Project for
%   use in the OpenSSL Toolkit (http://www.openssl.org/).
%   This product includes MD5 software written by Eric Young
%   (eay@cryptsoft.com).

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2010/03/22 03:42:24 $

% Simply pick up the default library
[primaryLib, extras] = distcomp.mpiLibConfs( 'default' );
