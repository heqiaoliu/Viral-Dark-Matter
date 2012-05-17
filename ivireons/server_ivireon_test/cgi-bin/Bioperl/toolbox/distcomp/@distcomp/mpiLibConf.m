function [primary, extras] = mpiLibConf( option )
% mpiLibConf - gateway which determines the MPI implementation to use

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/10/12 17:27:35 $

% This function is called by mpiLibConf and wraps the call to mpiLibConf, or
% overrides it if necessary.

% Logic: input argument is most powerful, then MDCE_FORCE_MPI_OPTION env
% var, finally use whatever mpiLibConf is in effect.

if nargin == 1
    [primary, extras] = distcomp.mpiLibConfs( option );
elseif ~isempty( getenv( 'MDCE_FORCE_MPI_OPTION' ) )
    [primary, extras] = distcomp.mpiLibConfs( getenv( 'MDCE_FORCE_MPI_OPTION' ) );
else
    [primary, extras] = mpiLibConf;
end
