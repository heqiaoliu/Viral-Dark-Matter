function hObject = getObjectFromPath(this, path)
%GETOBJECTFROMPATH Get the objectFromPath.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:46:50 $

hObject = this;

if isempty(path)
    return;
end

hObject = hObject.PropertyDb.getObjectFromPath(path);

% [EOF]
