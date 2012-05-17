function cellargout = pGetDisplayItems(obj, outputItemStruct)
; %#ok Undocumented
% gets the common display structure in terms of a cell list of structure
% for unsupported schedulers. All schedulers supported for display should
% override this function especially when they want to display their own
% specific properties.
% See pDefaultSingleObjDisplay for display format
% Copyright 2006-2009 The MathWorks, Inc.

% $Revision: 1.1.6.5 $  $Date: 2009/04/15 22:57:52 $

cellargout = cell(3, 1); % initialise number of output arguments
%outputItemStruct = struct('Header', '', 'Type', '', 'Names', '', 'Values', ''); 

% Define the three output items this function is going to return
% using the structure format passeed in as a parameter to this function
mainStruct = outputItemStruct; 
jobsStruct = outputItemStruct;
specificStruct = outputItemStruct; 
% three structures created are outputed as items in cell array cellargout


mainStruct.Header = 'HPC Server Scheduler';
mainStruct.Type = obj.Type;
mainStruct.Names = {'Type', 'ClusterSize', 'DataLocation', 'HasSharedFilesystem'};

if ~isempty(obj.storage)
    dataLoc = obj.storage.pGetDisplayItem();
else
    dataLoc =  obj.DataLocation;
end

mainStruct.Values = {obj.Type, obj.ClusterSize, dataLoc, obj.HasSharedFilesystem};


jobsStruct.Header = 'Assigned Jobs';
jobsStruct.Names = {'Number Pending ', 'Number Queued  ', 'Number Running ', 'Number Finished'};
try
    [p, q, r, f] = obj.findJob;
    jobsStruct.Values = {length(p), length(q), length(r), length(f)};
catch err %#ok<NASGU>
    % just display '[]' when the job objects are invalid
    jobsStruct.Values = { [], [], [], [] };
end

specificStruct.Header = 'HPC Server Specific Properties';
specificStruct.Type = '';
specificStruct.Names = {'ClusterMatlabRoot', 'SchedulerHostname', 'ClusterVersion', ...
    'JobTemplate', 'JobDescriptionFile', 'UseSOAJobSubmission'};
specificStruct.Values = {obj.ClusterMatlabRoot, obj.SchedulerHostname, obj.ClusterVersion, ...
    obj.JobTemplate, obj.JobDescriptionFile, obj.UseSOAJobSubmission};
% all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;   
cellargout{2} = jobsStruct;
cellargout{3} = specificStruct;
