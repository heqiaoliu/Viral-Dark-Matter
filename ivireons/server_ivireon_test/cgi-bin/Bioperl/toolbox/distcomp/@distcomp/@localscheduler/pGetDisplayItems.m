function cellargout = pGetDisplayItems(obj, outputItemStruct)
; %#ok Undocumented
% gets the common display structure in terms of a cell array of structures
% See pDefaultSingleObjDisplay for display format

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.3 $  $Date: 2007/08/20 16:26:52 $

cellargout = cell(3, 1); % initialise number of output arguments

% Define the three output items this function is going to return
mainStruct = outputItemStruct;
jobsStruct = outputItemStruct;
specificStruct = outputItemStruct;

mainStruct.Header = 'Local Scheduler';
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
catch
    % just display '[]' when the job objects are invalid
    jobsStruct.Values = { [], [], [], [] };
end
% specific properties

specificStruct.Header = 'Local Specific Properties';
specificStruct.Type = '';
specificStruct.Names = {'ClusterMatlabRoot'};
specificStruct.Values = {obj.ClusterMatlabRoot};
%  all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;   %
cellargout{2} = jobsStruct;
cellargout{3} = specificStruct;