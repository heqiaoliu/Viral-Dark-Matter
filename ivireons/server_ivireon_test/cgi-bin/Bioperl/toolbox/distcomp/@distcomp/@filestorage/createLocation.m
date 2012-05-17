function [location, ID] = createLocation(obj, parent, numberToCreate)
; %#ok Undocumented
%createLocation creates an empty location in the storage for an entity
%
%  LOCATION = CREATELOCATION(OBJ, PARENT, NUMBERTOCREATE)
%
% The input parent is a string without an extension, which uniquely
% identifies the parent of the locations we are trying to create

%  Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/05/05 21:35:59 $

% This is the mechanism by which a new location becomes allocated on the disk 

% Don't bother if the storage is read only
if obj.IsReadOnly
    error('distcomp:filestorage:InvalidFilePermissions', ...
        ['You do not have permission to write to the current StorageLocation : \n' ...
         '%s \n' ...
         'You should change directory to somewhere where you do have write permission'], obj.StorageLocation);
end
% TODO - mutex this creation on a lockfile in 

% Deal with vectorized creation and output a cell array of locations
CELL_OUTPUT = true;
if nargin < 3
    numberToCreate = 1;
    CELL_OUTPUT = false;
end

storageLocation = obj.StorageLocation;
if ~isempty(parent)
    % Check to see that the requested parent actually exists - if it does
    % ensure the child container exists, if not create it, and then return.
    % The function WILL THROW AN ERROR if the parent has ceased to exist
    % (for example if it has been destroyed by a different process)
    iEnsureChildContainerExists(obj, storageLocation, parent);
    parentLocation = [storageLocation filesep parent];
else
    parentLocation = storageLocation;
end
% Check if the storage metadata file exists
if ~obj.RootMetadataFileExists
    % Create the root metadata file
    obj.pCreateMetadataFile('');
    obj.RootMetadataFileExists = true;
end
% It is likely that an object with no parent is called a Job and an object
% with a parent is called a Task.
if isempty(parent)
    type = obj.JobLocationString;
    IS_JOB = true;
else
    type = obj.TaskLocationString;
    IS_JOB = false;
end
% Get the list of names and entity values from the location
[names, values] = pGetEntityNamesFromLocation(obj, parentLocation, type);
% We want the largest one, so that the next is one higher
lastValue = max(values);
if IS_JOB
    lastValue = max([lastValue obj.myLastJobValue]);
end
% An empty directory will return no names 
if isempty(lastValue) 
    lastValue = 0;
end
ID = zeros(1, numberToCreate);
location = cell(size(ID));
ADD_PARENT_STRING = ~isempty(parent);
% Invert the creation order to minimise the likelihood of two processes
% attempting to allocate the same job number
for i = numberToCreate:-1:1
    thisID = lastValue + i;
    % What is the name of this location
    thisLocation = sprintf([type '%d'], thisID);
    % For each defined extension we need to create a new file
    for j = 1:numel(obj.Extensions)
        % Get the full name of this file
        fullLocation = [parentLocation filesep thisLocation obj.Extensions{j}];
        try
            % Create the file and immediate close the handle
            f = fopen(fullLocation, 'w');
            % Error if we failed to open the file
            if f < 0
                error('distcomp:filestorage:InvalidFilePermissions', 'Unable to create file'); 
            end
            fclose(f);
        catch err
            rethrow(err);
        end
    end
    % Return the location string - note that parent might be empty and
    % hence you don't want the filesep in the string - unix filesep to
    % allow this name to be used on all platforms
    if ADD_PARENT_STRING
        thisLocation = [parent '/' thisLocation];
    end
    location{i} = thisLocation;
    ID(i) = thisID;
end
if IS_JOB && numel(ID) > 0
    obj.myLastJobValue = ID(end);
end

if ~CELL_OUTPUT
    location = location{1};
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iEnsureChildContainerExists(obj, storageLocation, parent)
% Next ensure that the container directory exists
if ~exist([storageLocation filesep parent], 'dir')
    % Check that the relevant parent files already exist
    for i = 1:numel(obj.Extensions)
        fullLocation = [storageLocation filesep parent obj.Extensions{i}];
        if ~exist(fullLocation, 'file')
            error('distcomp:filestorage:InvalidJob', ...
                'The expected job file %s does not exist', fullLocation);
        end
    end
    [OK, errorMessage, errorID] = mkdir(storageLocation, parent);
    OK = OK && obj.pCreateMetadataFile(parent);
    if ~OK
        error(errorID, errorMessage);
    end
end

