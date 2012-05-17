function value = pGetFullPCAndUnixStorageLocation(obj)
; %#ok Undocumented
% gets the full filestorage value.  If only one of pc or unix storage
% locations is specified, then just returns that location string.  If
% both pc and unix are specified, then returns a structure whose fields
% are determined by getStorageLocationStruct.

% Copyright 2009-2010 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:14:02 $

pcLocation = obj.WindowsStorageLocation;
unixLocation = obj.UnixStorageLocation;

% If only one of PC and Unix locations are specified, then 
% just return the default char location
if isempty(pcLocation) || isempty(unixLocation)
    value = char(obj);
else
    % We know we have both the pc and unix locations, so 
    % just return the structure provided by getStorageLocationStruct.
    value = obj.getStorageLocationStruct;
end

