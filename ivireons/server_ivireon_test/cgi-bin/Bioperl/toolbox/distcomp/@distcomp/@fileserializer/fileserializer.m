function obj = fileserializer(storage)
; %#ok Undocumented
%SERIALIZER abstract constructor for this class
%
%  OBJ = SERIALIZER(OBJ, STORAGE)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:08 $

% Construct the instance of this object
obj = distcomp.fileserializer;
% Set the storage location
obj.serializer(storage);