function pctWorldLabBarrier
; %#ok Undocumented

% This function will revert to using the world communicator to barrier. Irrespective
% of the current situation with the currently selected communicator all labs need
% to execute this statement

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/11/24 14:56:35 $

% Ensure that we are using the 'real' MPI rather than the 'faked' parfor one
% that uses the mpi_mi implementation.
dctRegisterMpiFunctions('mwmpi');
oldComm = mpiCommManip( 'select', 'world' );
try
    labBarrier;
catch err
    mpiCommManip( 'select', oldComm );
    rethrow(err);
end
mpiCommManip( 'select', oldComm );
