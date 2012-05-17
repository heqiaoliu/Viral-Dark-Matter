function obj = filestorage(dirinfo, warnOnPermissionError)
; %#ok Undocumented
%FILESTORAGE concrete constructor for this class
%
%  OBJ = FILESTORAGE(STORAGELOCATION)

%  Copyright 2000-2010 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2010/04/21 21:14:00 $

if nargin < 2
    warnOnPermissionError = true;
end

% NB if these field names change, then they need to be changed in 
% getStorageLocationStruct as well
pcField = 'pc';
unixField = 'unix';
% It is possible to supply both the unix and windows path to an LSF shared
% file system. This is done using a struct of the form a.pc and a.unix
if isstruct(dirinfo) && isfield(dirinfo, pcField) && isfield(dirinfo, unixField)
    if ispc
        storageDir = dirinfo.(pcField);
    else
        storageDir = dirinfo.(unixField);
    end
    windowsDir = dirinfo.(pcField);
    unixDir = dirinfo.(unixField);
elseif ischar(dirinfo)
    storageDir = dirinfo;
    windowsDir = '';
    unixDir = '';
    if ispc
        windowsDir = dirinfo;
    else
        unixDir = dirinfo;
    end
else
    error('distcomp:filestorage:InvalidArgument', 'The location property of a file store must be a char array or a struct with fields pc and unix');
end

% Make sure that the names don't contain the delimiter characters that we
% are going to use to transfer the information during serialization

obj = distcomp.filestorage;

% Before calling inherited constructor we set the warning level
set(obj, 'WarnOnPermissionError', warnOnPermissionError);
% Call inherited constructor
obj.abstractstorage(storageDir, distcomp.fileserializer(obj));
% Set the various computer specific locations - to an absolute path
if ispc
    windowsDir = obj.StorageLocation;
else
    unixDir = obj.StorageLocation;
end
set(obj, ...
    'WindowsStorageLocation', windowsDir,...
    'UnixStorageLocation', unixDir);

