function s = sigcontainer_getstate(hParent)
%GETSTATE Returns the state for the container and its components

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:03:35 $

s = siggui_getstate(hParent);

% Loop over all the children and get their states
for hindx = allchild(hParent),
    field = get(hindx.classhandle, 'Name');
    s.(field) = getstate(hindx);       
end

% [EOF]
