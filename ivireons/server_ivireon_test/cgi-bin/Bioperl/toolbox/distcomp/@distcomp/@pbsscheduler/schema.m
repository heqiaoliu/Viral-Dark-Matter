function schema
%SCHEMA defines the distcomp.pbsscheduler class
%

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 19:51:09 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractscheduler');
hThisClass   = schema.class(hThisPackage, 'pbsscheduler', hParentClass);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read-only configurations:
p = schema.prop(hThisClass, 'ServerName', 'string');
p.AccessFlags.PublicSet = 'off';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% User-configurable properties:
schema.prop(hThisClass, 'SubmitArguments', 'string');

schema.prop(hThisClass, 'ResourceTemplate', 'string' );

schema.prop(hThisClass, 'RcpCommand', 'string' );

schema.prop(hThisClass, 'RshCommand', 'string' );

schema.prop( hThisClass, 'ParallelSubmissionWrapperScript', 'string' );
p.SetFunction = @pSetParallelSubmissionWrapperScript;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Properties which are used only internally - never publically visible
p = schema.prop(hThisClass, 'UseJobArrays', 'bool' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'UsePbsAttach', 'bool' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% The two commands for qselecting queued/pending and running jobs/subjobs
p = schema.prop(hThisClass, 'StateIndicators', 'string vector' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
