function schema

%  Copyright 2000-2006 The MathWorks, Inc.
%  $Revision: 1.1.10.4 $    $Date: 2007/06/18 22:13:39 $ 

hThisPackage = findpackage( 'distcomp' );
hParentClass = hThisPackage.findclass( 'abstractscheduler' );
hThisClass   = schema.class( hThisPackage, 'mpiexec', hParentClass );

% Create an enumeration for the allowable environment types
if isempty(findtype('distcomp.mpiexecenvtype'))
    schema.EnumType('distcomp.mpiexecenvtype', ...
                    {'-env', 'setenv'}, [1 2]);
end

% The string used to call "MPIEXEC"
schema.prop( hThisClass, 'MpiexecFileName', 'string' );

% Extra command-line bits to tack on
schema.prop( hThisClass, 'SubmitArguments', 'string' );

% How to set the environment for the running processes
schema.prop( hThisClass, 'EnvironmentSetMethod', ...
             'distcomp.mpiexecenvtype' ); % "-env" or "setenv"

% Need to know this, sadly
p = schema.prop( hThisClass, 'WorkerMachineOsType', ...
             'distcomp.workertype' ); %'pc', 'unix' or 'mixed'
p.SetFunction = @iSetWorkerMachineOsType;
p.GetFunction = @iGetWorkerMachineOsType;
p.AccessFlags.Init = 'on';
if ispc
    p.FactoryValue = 'pc';
else
    p.FactoryValue = 'unix';
end

% This allows unit-testing on one host of the PID stuff
p = schema.prop( hThisClass, 'ClientHostName', 'string' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

%--------------------------------------------------------------------------------
%
%--------------------------------------------------------------------------------
function val = iSetWorkerMachineOsType(obj, val)
% Set the real value we care about in the base class
obj.ClusterOsType = val;
% Warn about obsolete property
warning('distcomp:mpiexec:WorkerMachineOsTypeObsolete', ...
    '%s\n%s', ...
    'The property WorkerMachineOsType of an mpiexec scheduler will be obsoleted in a future version.', ...
    'Please use the property ClusterOsType instead.');    
% And turn warning off    
warning( 'off', 'distcomp:mpiexec:WorkerMachineOsTypeObsolete')

%--------------------------------------------------------------------------------
%
%--------------------------------------------------------------------------------
function val = iGetWorkerMachineOsType(obj, val)
val = obj.ClusterOsType;
