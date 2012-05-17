function value = getStorageLocationStruct(obj)
; %#ok Undocumented
% 
% Returns information about the storage in a structure whose fields
% currently contain 'pc' and 'unix'.  The presence of these fields is
% not guaranteed.
% Currently used by genericscheduler.getDataLocation.
% 

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2010/04/21 21:14:01 $

value = struct('pc', obj.WindowsStorageLocation, 'unix', obj.UnixStorageLocation);
