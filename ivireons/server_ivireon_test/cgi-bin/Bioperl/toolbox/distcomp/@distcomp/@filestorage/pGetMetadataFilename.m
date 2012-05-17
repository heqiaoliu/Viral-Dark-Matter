function filename = pGetMetadataFilename(storage, parent)
; %#ok Undocumented
%pGetMetadataFilename 
%
% filename = pGetMetadataFilename(storage, parent)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:31 $

if isempty(parent)
    filename = [storage.StorageLocation filesep storage.MetadataFilename];
else
    filename = [storage.StorageLocation filesep parent filesep storage.MetadataFilename];
end