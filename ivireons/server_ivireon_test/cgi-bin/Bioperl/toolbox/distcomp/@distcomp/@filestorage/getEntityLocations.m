function [locations, IDs] = getEntityLocations(obj, parent)
; %#ok Undocumented
%getEntityLocation gets the valid entities from the storage location
%
%  LOCATIONS = GETENTITYLOCATION(OBJ, PARENT)
%
% The input parent is a string without an extension, which uniquely
% identifies the parent of the locations we are trying to create

%  Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/03/31 17:07:26 $

% This is the mechanism by which a new location becomes allocated on the disk 

% TODO - mutex this creation on a lockfile in 

storageLocation = obj.StorageLocation;
if ~isempty(parent)
    % Check to see that the requested parent actually exists - if it does
    % ensure the child container exists, if not create it, and then return.
    % The function WILL THROW AN ERROR if the parent has ceased to exist
    % (for example if it has been destroyed by a different process)
    storageLocation = [storageLocation filesep parent];
end
% It is likely that an object with no parent is called a Job and an object
% with a parent is called a Task.
if isempty(parent)
    type = obj.JobLocationString;
else
    type = obj.TaskLocationString;
end
% Get the list of names and entity values from the location
[locations, IDs] = pGetEntityNamesFromLocation(obj, storageLocation, type);
% Note that these are not sorted, so sort by value
[IDs, index] = sort(IDs);
locations = locations(index);
% Need to add the parent to the beginning if it isn't empty
if ~isempty(parent)
    for i = 1:numel(locations)
        locations{i} = [parent '/' locations{i}];
    end
end
    

