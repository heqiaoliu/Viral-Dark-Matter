function schema
%SCHEMA defines the distcomp.filestorage class
%

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2010/03/31 18:13:59 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractstorage');
hThisClass   = schema.class(hThisPackage, 'filestorage', hParentClass);

p = schema.prop(hThisClass, 'Extensions', 'string vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = {'.common.mat' '.in.mat' '.jobout.mat' '.out.mat' '.state.mat'};
commonIndex = 1;
inIndex = 2;
joboutIndex = 3;
outIndex = 4;
stateIndex = 5;

p = schema.prop(hThisClass, 'FileFormat', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = { 'DATE_FILE' 'MAT_FILE' 'DATE_FILE' 'MAT_FILE' 'STATE_FILE' };

% The intention of this field is to hold the names of different fields in
% abstractdataentity subclasses and indicate which extension that field
% should be stored in.
p = schema.prop(hThisClass, 'FieldToExtensionTransform', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';

jobIn      = sort({ 'name' 'productkeys' 'username' 'tag' 'createtime' 'submittime' ... 
    'filedependencies' 'filedata' 'pathdependencies' 'jobdata' 'jobschedulerdata' 'execmode' 'version' ...
    'maxworkers', 'minworkers'});
jobCommon  = sort({ 'starttime' });
jobOut     = sort({ 'finishtime' });
jobState   = sort({ 'state' });

taskIn     = sort({ 'name' 'taskfunction' 'argsin' 'nargout' 'capturecommandwindowoutput' 'createtime' });
taskCommon = sort({ 'starttime'});
taskOut    = sort({ 'argsout' 'errorstruct' 'errormessage' 'erroridentifier' 'finishtime' 'commandwindowoutput'});
taskState  = sort({ 'state' });

p.FactoryValue = struct( ...
    'Type', {'job' 'task'}, ...
    'FieldName', { [ jobIn jobCommon jobOut jobState ] [ taskIn taskCommon taskOut taskState ] }, ...
    'ExtensionIndex', { ...
    [inIndex*ones(size(jobIn))  commonIndex*ones(size(jobCommon))  joboutIndex*ones(size(jobOut))  stateIndex*ones(size(jobState))] ...
    [inIndex*ones(size(taskIn)) commonIndex*ones(size(taskCommon)) outIndex*ones(size(taskOut)) stateIndex*ones(size(taskState))] ...
    });


p = schema.prop(hThisClass, 'MetadataFilename', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'matlab_metadata.mat';

p = schema.prop(hThisClass, 'RootMetadataFileExists', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

schema.prop(hThisClass, 'WindowsStorageLocation', 'string');

schema.prop(hThisClass, 'UnixStorageLocation', 'string');

% This is a field that is used to ensure that each job from this storage
% will get an incrementing value, even if the previous one has been 
% destroyed. This is a workaround to NFS cache problems for mpiexec
% particularly, where the machine on which the job is about to run 
% still has the previous job and task in NFS cache memory. Thus they
% are unable to run the new one until the cache has flushed. If the 
% name changes then this problem does not occur - however we need to 
% consider the possibility that multiple machines will ba accessing
% the same file storage simultaneously.
p = schema.prop(hThisClass, 'myLastJobValue', 'double');
p.AccessFlags.Init = 'on';
p.FactoryValue = 0;

schema.prop(hThisClass, 'WarnOnPermissionError', 'bool');

p = schema.prop(hThisClass, 'JobLocationString', 'string');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'Job';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'TaskLocationString', 'string');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'Task';
p.AccessFlags.PublicSet = 'off';
