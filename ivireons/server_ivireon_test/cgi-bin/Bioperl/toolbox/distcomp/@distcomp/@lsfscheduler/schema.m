function schema
%SCHEMA defines the distcomp.lsfscheduler class
%

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2007/06/18 22:13:34 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractscheduler');
hThisClass   = schema.class(hThisPackage, 'lsfscheduler', hParentClass);

p = schema.prop(hThisClass, 'ClusterName', 'string');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'MasterName', 'string');
p.AccessFlags.PublicSet = 'off';

schema.prop(hThisClass, 'SubmitArguments', 'string');

% The wrapper script - SetFunction interprets special values
p = schema.prop( hThisClass, 'ParallelSubmissionWrapperScript', 'string' );
p.SetFunction = @pSetParallelSubmissionWrapperScript;
