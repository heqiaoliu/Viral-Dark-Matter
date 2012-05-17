function obj = abstractstorage(obj, storageLocation, serializer)
; %#ok Undocumented
%ABSTRACTSTORAGE abstract constructor for this class
%
%  OBJ = ABSTRACTSTORAGE(OBJ, STORAGELOCATION)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:10 $


set(obj, ...
    'StorageLocation', storageLocation, ...
    'Serializer', serializer);