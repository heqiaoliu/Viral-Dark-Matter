function cellargout = pGetDisplayItems(obj,outputItemStruct)
; %#ok Undocumented
% gets the common display structure in terms of a cell array of structures
% See pDefaultSingleObjDisplay for display format

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.4 $  $Date: 2008/03/31 17:07:41 $

cellargout = cell(3, 1); % initialise number of output arguments

% Define the three output items this function is going to return
mainStruct = outputItemStruct; 
jobsStruct = outputItemStruct;
specificStruct = outputItemStruct;
% these are assigned to  cellargout at end of function

mainStruct.Header = 'LSF Scheduler';
mainStruct.Type = obj.Type;
mainStruct.Names = {'Type', 'ClusterOsType', 'ClusterSize', 'DataLocation', 'HasSharedFilesystem'};
% top level display truncates as before but can now deal with
% structs with members pc and unix

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
catch
    % just display '[]' when the job objects are invalid
    jobsStruct.Values = { [], [], [], [] };
end

% specific properties
specificStruct.Header = 'LSF Specific Properties';
specificStruct.Names = {'ClusterMatlabRoot', 'ClusterName', 'MasterName', 'SubmitArguments'};
specificStruct.Values = {obj.ClusterMatlabRoot, obj.ClusterName, obj.MasterName, obj.SubmitArguments };
% all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;   
cellargout{2} = jobsStruct;
cellargout{3} = specificStruct;
