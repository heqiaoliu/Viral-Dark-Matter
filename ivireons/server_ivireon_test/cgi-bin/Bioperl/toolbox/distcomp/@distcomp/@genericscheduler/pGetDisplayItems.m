function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
% gets the common display structure in terms of a cell array of structures
% See pDefaultSingleObjDisplay for display format

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.4 $  $Date: 2008/05/19 22:45:01 $


cellargout = cell(3, 1); % initialise number of output arguments

% Define the three output items this function is going to return
mainStruct = inStruct; 
jobsStruct = inStruct;
specificStruct = inStruct;


mainStruct.Header = [upper(obj.Type) ' Scheduler']; 
mainStruct.Type = obj.Type;
mainStruct.Names = {'Type', 'ClusterOsType', 'ClusterSize', 'DataLocation', 'HasSharedFilesystem'};

if ~isempty(obj.storage)
    dataLoc = obj.storage.pGetDisplayItem();
else
    dataLoc =  obj.DataLocation;
end
mainStruct.Values = {obj.Type, obj.ClusterOsType, obj.ClusterSize, dataLoc, obj.HasSharedFilesystem};

jobsStruct.Header = 'Assigned Jobs';
jobsStruct.Names = {'Number Pending ', 'Number Queued  ', 'Number Running ', 'Number Finished'};
try
    [p, q, r, f] = obj.findJob;
    jobsStruct.Values = {length(p), length(q), length(r), length(f)};
catch err %#ok<NASGU>
    % just display '[]' when the job objects are invalid
    jobsStruct.Values = { [], [], [], [] };
end

% specific properties
specificStruct.Header = 'Scheduler Specific Properties';
specificStruct.Names = {'ClusterMatlabRoot', 'ParallelSubmitFcn', 'SubmitFcn', 'GetJobStateFcn', ...
    'CancelJobFcn', 'CancelTaskFcn', 'DestroyJobFcn', 'DestroyTaskFcn'};
specificStruct.Values = {obj.ClusterMatlabRoot, obj.ParallelSubmitFcn, obj.SubmitFcn, obj.GetJobStateFcn, ...
    obj.CancelJobFcn, obj.CancelTaskFcn, obj.DestroyJobFcn, obj.DestroyTaskFcn};

cellargout{1} = mainStruct;   % all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{2} = jobsStruct;
cellargout{3} = specificStruct;