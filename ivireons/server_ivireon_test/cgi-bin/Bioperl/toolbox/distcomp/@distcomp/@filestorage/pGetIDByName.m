function ID = pGetIDByName(storage, entityLocation)
; %#ok Undocumented
%pGetIDByName 
%
%  ID = GETPROXYBYNAME(STORAGE, LOCATION)
%
% 

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:30 $


% Extract the ID from the location - it's the digits at the end of the
% Location.
strID = regexp(entityLocation, '\d*$', 'match', 'once');
ID = sscanf(strID, '%d');
if isempty(ID)
    error('distcomp:filestorage:InvalidArgument', 'The location of an entity must end in it''s ID - an integer greater than zero');
end
