function values = getFields(obj, entities, names)
; %#ok Undocumented
%getFields
%
%  GETFIELDS(SERIALIZER, LOCATION, NAMES)

% Copyright 2004-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2008/05/05 21:35:58 $

numEntities = numel(entities);
numNames = numel(names);
% Ensure the names and values are rows
names = reshape(names, 1, numNames);
% Pre-create output array
values = cell(numEntities, numNames);
% If there are no entities then return an empty array early
if numEntities == 0
    return
end

% Get retry information
[pauseDuration, pauseMultiplier, numRetries] = obj.getRetryInformation;

storage = obj.Storage;
% Ensure that we have a location plus a file seperator
locationStart = fullfile(storage.StorageLocation, filesep);

% Need to decide which names go in which internal files
[extensions, fileFormats] = storage.pGetExtensionsForFields(entities(1).pGetEntityType, names);

% Order by common extension - the output index is the index into the new
% extensions array for the equivalent name
[extensions, I, J] = unique(extensions);
fileFormats = fileFormats(I);

% Get all entityLocations outside the loop
entityLocations = cell(numEntities, 1);
for i = 1:numEntities
    entityLocations{i} = entities(i).pGetEntityLocation;
end

% Now actually save the fields and values
for i = 1:numel(extensions)
    % Which names are saved in this file
    indexToLoad = find(J == i);
    namesToLoad = names(indexToLoad);
    % Get this extension
    extension = extensions{i};
    % Define the load function to use
    switch fileFormats{i}
        case 'MAT_FILE'
            loadFunction = @iLoadMat;
        case 'STATE_FILE'
            loadFunction = @iLoadState;
        case 'DATE_FILE'
            loadFunction = @iLoadDate;
    end
    % Loop over the supplied entities
    for j = 1:numEntities
        % Get the complete name of this location
        thisLocation = [locationStart entityLocations{j} extension];        
        % Load the appropriate things - note that this might throw an error so lets
        % try loading a few times to see if we can deal with such problems
        DONE = false;
        err = '';
        for k = 1:numRetries
            try
                % Load the appropriate things
                loadedData = loadFunction(obj, thisLocation, namesToLoad{:});
                % Construct a structure to save from
                values(j, indexToLoad) = loadedData;
                % Indicate that we actually succeeded
                DONE = true;
                break;
            catch exception
                pause(pauseDuration);
                pauseDuration = pauseMultiplier*pauseDuration;
                err = exception;
            end
        end
        if ~DONE
            throw(err);
        end
    end
end

%--------------------------------------------------------------------------
% Definition of the MAT File
%--------------------------------------------------------------------------
function data = iLoadMat(obj, filename, varargin)
loadedStruct = load(filename, varargin{:});
% Part of the contract of the load function is that the fields in the
% structure are in the same order as sent in - so ensure that the
% reordering occurs here - NOTE that there is an optimisation when there is
% only one name i.e. calling struct2cell
numNames = numel(varargin);
if  numNames == 1
    data = struct2cell(loadedStruct);
else
    data = cell(numNames, 1);
    for i = 1:numNames 
        data{i} = loadedStruct.(varargin{i});
    end
end
%--------------------------------------------------------------------------
% Definition of the State File
%--------------------------------------------------------------------------
function data = iLoadState(obj, filename, varargin)
% If we get in here then the data to be saved has a state field
fid = fopen(filename, 'r');
if fid > 0
    state = fgetl(fid);
    fclose(fid);
    % Need to check that we actually got string data
    if ischar(state) && any(strcmp(state, obj.ValidStateStrings))
        data = {state};
    else
        error('distcomp:fileserializer:IOError', 'State file does not contain string data');
    end
else
    error('distcomp:fileserializer:IOError', 'Unable to open state file');
end

%--------------------------------------------------------------------------
% Definition of the Date File
%--------------------------------------------------------------------------
function data = iLoadDate(obj, filename, varargin)
% If we get in here then the data to be saved has a date field
fid = fopen(filename, 'r');
if fid > 0
    date = fgetl(fid);
    fclose(fid);
    if ~ischar( date )
        data = {''};
    else
        data = {date};
    end
else
    error('distcomp:fileserializer:IOError', 'Unable to open file: %s', filename);
end
