function schema
%SCHEMA defines the distcomp.ccsscheduler class
%

%   Copyright 2006-2009 The MathWorks, Inc.

%   $Revision: 1.1.6.7 $  $Date: 2009/04/15 22:58:11 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractscheduler');
hThisClass   = schema.class(hThisPackage, 'ccsscheduler', hParentClass);

p = schema.prop(hThisClass, 'SchedulerHostname', 'string');
p.AccessFlags.init = 'on';
p.FactoryValue = 'localhost';
p.SetFunction = @pSetSchedulerHostname;

% Private property that is the object that connects to a scheduler.
% Note that it is possible for this to not be correctly connected, based on
% the value of SchedulerHostname
p = schema.prop(hThisClass, 'ServerConnection', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Note that this defaults to false - which is essential
p = schema.prop(hThisClass, 'Initialized', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Public property to allow user to choose if SOA API should be used for simple jobs
% Note that this is supported only by v2
p = schema.prop(hThisClass, 'UseSOAJobSubmission', 'bool');
p.AccessFlags.init = 'on';
p.FactoryValue = false;
p.SetFunction = @pSetUseSOAJobSubmission;
p.GetFunction = @pGetUseSOAJobSubmission;
p.AccessFlags.AbortSet = 'off';

% Public property to allow user to set the job template
% Note that this is supported only by v2
p = schema.prop(hThisClass, 'JobTemplate', 'string');
p.AccessFlags.init = 'on';
p.FactoryValue = '';
p.SetFunction = @pSetJobTemplate;
p.GetFunction = @pGetJobTemplate;
p.AccessFlags.AbortSet = 'off';

% Public property to allow user to set the job XML Description file
p = schema.prop(hThisClass, 'JobDescriptionFile', 'string');
p.AccessFlags.init = 'on';
p.FactoryValue = '';
p.SetFunction = @pSetJobDescriptionFile;
p.GetFunction = @pGetJobDescriptionFile;
p.AccessFlags.AbortSet = 'off';

% Enum to indicate which cluster version we are using for ccsscheduler
if isempty(findtype('distcomp.microsoftclusterversion'))
    schema.EnumType('distcomp.microsoftclusterversion', ...
        {'CCS', 'HPCServer2008'}, [1 2]);
end

% Public property to allow user to select which type of cluster they wish to use
p = schema.prop(hThisClass, 'ClusterVersion', 'distcomp.microsoftclusterversion'); % 'CCS' or 'HPC Server 2008'
p.AccessFlags.AbortSet  = 'on';
p.AccessFlags.init = 'on';
p.FactoryValue = 'HPCServer2008'; % initialize to the latest cluster version
p.SetFunction = @pSetClusterVersion;

% Private property that indicates whether or not we have tested that
% this really is a CCS/HPC Server Client machine
p = schema.prop(hThisClass, 'HaveTestedForMicrosoftClientUtilities', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.init = 'on';
p.FactoryValue = false;
