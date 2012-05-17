function pAddConstructorToMetadata(storage, parent, constructor, IDs)
; %#ok Undocumented
%pAddConstructorToMetadata 
%
% pAddConstructorToMetadata(fileStorage, constructor, IDs)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:36:00 $

% Do nothing with an empty constructor
if ~isa(constructor, 'function_handle')
    error('distcomp:filestorage:InvalidArgument', 'The constructor argument must be a function handle');
end
metadataFilename = storage.pGetMetadataFilename(parent);

try
    % Load the metadata
    data = load(metadataFilename);
catch
    % Default to throwing an error
    OK = false;
    % Did this fail because the metedata file simply didn't exist - perhaps
    % the user went and deleted it whilst we were still running MATLAB?
    if ~exist(metadataFilename, 'file')
        try
            % Lets try and re-create the file
            OK = storage.pCreateMetadataFile(parent);
            % If we succeed then get the data from it
            if OK
                data = load(metadataFilename);
            end
        end
    end
    if OK
        warning('distcomp:filestorage:InvalidState', 'The storage metadata file did not exist. Recreating it.');
    else
        error('distcomp:filestorage:InvalidState', 'The storage metadata file is corrupt. Please delete all files in the DataLocation and try again');
    end
end    

% If this one is equal to the default do nothing
if isequal(constructor, data.DefaultConstructor)
    % Need to ensure that my IDs are not in the list of IDsUsingAlternatives
    [data.IDsUsingAlternative, indexToKeep] = setdiff(data.IDsUsingAlternative, IDs);
    % Return early if none found
    if numel(indexToKeep) == numel(data.AlternativeConstructorIndex)
        return
    end
    data.AlternativeConstructorIndex = data.AlternativeConstructorIndex(indexToKeep);
else
    % Not the default - check if it is in the list of alternatives
    alternativeConstructors = data.AlternativeConstructors;
    FOUND = false;
    foundAtIndex = 0;
    while ~FOUND && foundAtIndex < numel(alternativeConstructors)
        foundAtIndex = foundAtIndex + 1;
        FOUND = isequal(alternativeConstructors{foundAtIndex}, constructor);
    end
    % If it wasn't found then add it to the list of possible constructors
    if ~FOUND
        data.AlternativeConstructors{end + 1} = constructor;
        foundAtIndex = numel(data.AlternativeConstructors);
    end
    % Add the new IDs and index to the end of the existing values
    IDsUsingAlternative = [data.IDsUsingAlternative ; IDs(:)];
    AlternativeConstructorIndex = [data.AlternativeConstructorIndex ; repmat(foundAtIndex, numel(IDs), 1)];
    % We don't know if we have duplicated the ID's by adding them above so we need
    % to ensure that we remove any duplicates
    [data.IDsUsingAlternative, indexToKeep] = unique(IDsUsingAlternative, 'last');
    data.AlternativeConstructorIndex = AlternativeConstructorIndex(indexToKeep);
end

try
    % Try and save the metadata file
    save(metadataFilename, '-struct', 'data');
catch err
    rethrow(err);
end
