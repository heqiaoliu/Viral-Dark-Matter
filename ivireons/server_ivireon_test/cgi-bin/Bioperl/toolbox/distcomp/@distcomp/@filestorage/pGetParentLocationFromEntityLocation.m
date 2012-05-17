function parentLocation = pGetParentLocationFromEntityLocation(storage, entityLocation)
; %#ok Undocumented
%pGetParentLocationFromEntityLocation 
%
% parentLocation = pGetParentLocationFromEntityLocation(storage, entityLocation)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:32 $

% Find everything up to the last '/' 
parentLocation = regexp(entityLocation, '^.*/', 'match', 'once');
% Then remove the '/'
if ~isempty(parentLocation)
    parentLocation(end) = '';
end