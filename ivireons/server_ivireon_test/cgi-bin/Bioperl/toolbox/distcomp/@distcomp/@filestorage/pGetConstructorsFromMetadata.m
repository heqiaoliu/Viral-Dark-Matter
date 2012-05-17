function constructors = pGetConstructorsFromMetadata(storage, parent, IDs)
; %#ok Undocumented
%pGetConstructorsFromMetadata 
%
% constructor = pGetConstructorsFromMetadata(fileStorage, IDs)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:27 $

% Default return
constructors = [];
if isempty(IDs) 
    return
end

metadataFilename = storage.pGetMetadataFilename(parent);

try
    % Load the metadata
    data = load(metadataFilename);
catch
    error('distcomp:filestorage:InvalidState', 'The storage metadata file does not exist or is corrupt');
end

try
    % Try and find the IDs amongst the IDsUsingAlternative
    [found, index] = ismember(IDs, data.IDsUsingAlternative);
    index(found) = data.AlternativeConstructorIndex(index(found));
    % Are they all the same?
    if all(index == index(1))
        if found(1)
            constructors = data.AlternativeConstructors{index(1)};
        else
            constructors = data.DefaultConstructor;
        end
    else
        % All different so create a cell array to deal with all of them
        constructors = cell(size(IDs));
        for i = 1:numel(IDs)
            if found(i)
                thisConstructor = data.AlternativeConstructors{index(i)};
            else
                thisConstructor = data.DefaultConstructor;
            end
            constructors{i} = thisConstructor;
        end
    end
catch
end
