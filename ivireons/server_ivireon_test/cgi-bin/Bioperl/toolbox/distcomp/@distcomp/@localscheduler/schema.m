function schema

%  Copyright 2000-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $    $Date: 2009/07/14 03:53:03 $ 

hThisPackage = findpackage( 'distcomp' );
hParentClass = hThisPackage.findclass( 'abstractscheduler' );
hThisClass   = schema.class( hThisPackage, 'localscheduler', hParentClass );

% Do we want to remove the DataLocation if we are deleted - this is really
% waiting for Shutdown hooks to be available in the matlab JVM which are
% currently no implemented
p = schema.prop(hThisClass, 'RemoveDataLocation', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'Listeners', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'LocalScheduler', 'com.mathworks.toolbox.distcomp.local.LocalScheduler');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Note that this defaults to false - which is essential
p = schema.prop(hThisClass, 'Initialized', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Note that this defaults to false - which is essential
p = schema.prop(hThisClass, 'MaximumNumberOfWorkers', 'double');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Hold information about this process/machine. Each job created by the
% scheduler will be tagged with this information which should allow a
% decision to be made about how to interpret the job state.
p = schema.prop(hThisClass, 'ProcessInformation', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';