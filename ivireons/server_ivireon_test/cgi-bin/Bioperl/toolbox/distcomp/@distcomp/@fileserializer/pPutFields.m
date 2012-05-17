function pPutFields(obj, entities, names, values, saveFlags)
; %#ok Undocumented
%pPutFields private put field function which has flags to save
%
%  PPUTFIELDS(SERIALIZER, LOCATION, NAMES, VALUES)

% Copyright 2004-2006 The MathWorks, Inc.

numEntities = numel(entities);
if numel(names) ~= numel(values)
    error('distcomp:fileserializer:InvalidArgument', 'The number of fields and values to save must bethe same');
end
% Return early if there is nothing to put into
if numEntities == 0
    return
end
% Ensure the names and values are columns
names = reshape(names, numel(names), 1);
values = reshape(values, numel(values), 1);

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
    % Get this extension
    extension = extensions{i};
    % Which names are saved in this file
    indexToSave = find(J == i);
    % Construct a structure to save from
    structToSave = cell2struct(values(indexToSave), names(indexToSave));
    % Define the load function to use
    switch fileFormats{i}
        case 'MAT_FILE'
            saveFunction = @iSaveMat;
        case 'STATE_FILE'
            saveFunction = @iSaveState;
        case 'DATE_FILE'
            saveFunction = @iSaveDate;
    end
    for j = 1:numEntities
        % Get the complete name of this location
        thisLocation = [locationStart entityLocations{j} extension];        
        saveFunction(thisLocation, structToSave, saveFlags);
    end

end

%--------------------------------------------------------------------------
% Definition of the State File
%--------------------------------------------------------------------------
function iSaveState(filename, data, saveFlags)
% If we get in here then the data to be saved has a state field
fid = fopen(filename, 'w');
if fid > 0
    fprintf(fid, '%s\n', data.state);
    fclose(fid);
else
    error('distcomp:fileserializer:IOError', 'Unable to open state file');
end

%--------------------------------------------------------------------------
% Definition of the Mat File 
%--------------------------------------------------------------------------
function iSaveMat(filename, data, saveFlags)
save(filename, '-struct', 'data', saveFlags);

%--------------------------------------------------------------------------
% Definition of the Date File 
%--------------------------------------------------------------------------
function iSaveDate( filename, data, saveFlags ) %#ok<INUSD>

toWrite = '';
if isstruct( data )
    fn  = fieldnames( data );
    % only ever pick starttime or finishtime. Urgh.
    if ismember( 'starttime', fn ) && ischar( data.starttime )
        toWrite = data.starttime;
    elseif ismember( 'finishtime', fn ) && ischar( data.finishtime )
        toWrite = data.finishtime;
    else
        warning( 'distcomp:fileserializer:unknownField', ...
                 'Didn''t find expected field in data to save to %s', ...
                 filename );
    end
end

fid = fopen( filename, 'wt' );
if fid > 0
    fprintf( fid, '%s', toWrite );
    fclose( fid );
else
    % only warn - might get here (especially on windows) if a concurrent write
    % is in progress.
    warning('distcomp:fileserializer:IOError', 'Unable to open file: %s', filename);
end
