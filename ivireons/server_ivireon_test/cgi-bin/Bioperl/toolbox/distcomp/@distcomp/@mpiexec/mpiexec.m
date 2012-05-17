function obj = mpiexec( proxyScheduler )
; %#ok Undocumented
%MPIEXEC - mpiexec scheduler constructor

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:13:37 $ 

% Always turn the obsolete warning off because the constructor below will
% throw this warning
warnState = warning( 'off', 'distcomp:mpiexec:WorkerMachineOsTypeObsolete');
obj = distcomp.mpiexec;
% Turn back on ready for the first call to set WorkerMachineOsType
warning(warnState);

fullmpiexecpath = fullfile( matlabroot, 'bin', dct_arch, 'mpiexec' );

set( obj, ...
     'Type', 'mpiexec', ...
     'Storage', handle( proxyScheduler.getStorageLocation ), ...
     'MpiexecFileName', fullmpiexecpath, ...
     'ClientHostName', char( java.net.InetAddress.getLocalHost.getCanonicalHostName ), ...
     'EnvironmentSetMethod', '-env', ... % This works with MPICH2
     'HasSharedFilesystem', true );

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);
