function pRemoveEntityFromMetadata(storage, parent, IDs)
; %#ok Undocumented
%pRemoveEntityFromMetadata 
%
% pRemoveEntityFromMetadata(fileStorage, IDs)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:34 $


metadataFilename = storage.pGetMetadataFilename(parent);
try
    % Load the metadata
    data = load(metadataFilename);
catch
    error('distcomp:filestorage:InvalidState', 'The storage metadata file does not exist or is corrupt');
end    
% TODO - add more here!