function cellargout = pGetDisplayItems(obj, outputItemStruct)
; %#ok Undocumented
% gets the common display structure in terms of a cell list of structure
% in a default format for schedulers which have no particularly interesting specific information.
% All schedulers supported for display should
% override this function especially when they want to display their own
% specific properties. Currently overwritten for all schedulers

% Copyright 2006 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2007/06/18 22:11:14 $
% See pDefaultSingleObjDisplay for display format
cellargout = cell(3, 1); % initialise number of output arguments

% Define the three output items this function is going to return
mainStruct = outputItemStruct;
jobsStruct = outputItemStruct;
specificStruct = outputItemStruct;


mainStruct.Header = [upper(obj.Type) ' Scheduler']; % can be empty. specifies added text that should appear with this header
mainStruct.Type = obj.Type;
mainStruct.Names = {'Type', 'ClusterOsType', 'DataLocation', 'HasSharedFilesystem'};

if ~isempty(obj.storage)
    dataLoc = obj.storage.pGetDisplayItem();
else
    dataLoc =  obj.DataLocation;
end

mainStruct.Values = {obj.Type, obj.ClusterOsType, dataLoc, obj.HasSharedFilesystem};

jobsStruct.Header = 'Assigned Jobs';
jobsStruct.Names = {'Number Pending ', 'Number Queued  ', 'Number Running ', 'Number Finished'};
try
    [p, q, r, f] = obj.findJob;
    jobsStruct.Values = {length( p ), length( q ), length( r ), length( f )};
catch
    jobsStruct.Values = { [], [], [], [] };
end

% specific properties
specificStruct.Header = 'Specific Properties';
specificStruct.Type = '';
specificStruct.Names = {'ClusterMatlabRoot'};
specificStruct.Values = {obj.ClusterMatlabRoot};
% all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;
cellargout{2} = jobsStruct;
cellargout{3} = specificStruct;
