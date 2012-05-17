function [primary, extras] = mpiLibConfs( option )
%MPILIBCONFS - internal switchyard to pick MPI implementation

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/10/12 17:27:36 $

error( nargchk( 1, 1, nargin, 'struct' ) );

if strcmp( option, 'default' )
    % Different default for MAC because ssm not available.
    if ismac
        option = 'sock';
    else
        option = 'ssm';
    end
end

switch option
  case { 'ssm' }
    if ismac
        error( 'distcomp:mpiLib:BadLibOption', ...
               'The ''ssm'' MPI library option is not available on MAC.' );
    end
    [primary, extras] = iMpich( 'ssm' );
  case { 'sock' }
    [primary, extras] = iMpich( 'sock' );
  case 'msmpi'
    [primary, extras] = iMSMPI();
  otherwise
    error( 'distcomp:mpiLib:BadLibOption', ...
           'Unknown MPI library option: %s.', option );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [primary, extras] = iMSMPI()
if strcmp( computer, 'PCWIN64' )
    primary = 'msmpi.dll';
    extras  = {};
else
    error( 'distcomp:mpi:BadComputer', ...
           'Computer type "%s" does not have MSMPI support.', computer );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [primary, extras] = iMpich( variant )
extras = {};
% MPICH-specific port configuration
iPortConfiguration;

switch computer
  case {'PCWIN', 'PCWIN64'}
    switch variant
      case 'sock'
        primary = 'mpich2.dll';
      case 'ssm'
        primary = 'mpich2ssm.dll';
      otherwise
        error( 'distcomp:mpi:unknownvariant', ...
               'Unknown MPI variant: %s.', variant );
    end
  case {'GLNXA64', 'GLNX86'}
    primary = sprintf( 'libmpich%s.so', variant );
  case {'MAC', 'MACI', 'MACI64'}
    extras  = {sprintf( 'libmpich%s.dylib', variant )};
    primary = sprintf( 'libpmpich%s.dylib', variant );
  otherwise
    error( 'distcomp:mpi:unknowncomputer', ...
           'Computer type "%s" does not have MPI support.', computer );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iPortConfiguration - set up MPICH_PORT_RANGE based on our BASE_PORT
% environment variable.
function iPortConfiguration

base_port = str2double( getenv( 'BASE_PORT' ) );
if ~isnan( base_port )
    % MPI Communications start at BASE_PORT+1000, and we leave ourselves another
    % 1000 ports. If there are more than 1000 workers on a single machine,
    % MPI may therefore fail to open a port.
    bottom_port = base_port + 1000; 
    top_port = base_port + 2000;
    % format the env var for MPICH
    port_str = sprintf( '%d:%d', bottom_port, top_port );
    setenv( 'MPICH_PORT_RANGE', port_str );
end
end
