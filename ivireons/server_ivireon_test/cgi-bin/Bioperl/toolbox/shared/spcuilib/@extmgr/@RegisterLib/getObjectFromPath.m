function hObject = getObjectFromPath(this, path)
%GETOBJECTFROMPATH Get the objectFromPath.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:47:14 $

% A valid path at the RegisterLib level should start with 'Library'.  If it
% does not, we assume that it starts with the identification of a
% registration database.

% The 'path' should be a valid DDG Tree path, using the '/' character to
% delineate the objects.

hObject = this;

[registerName, path] = strtok(path, '/');

% If we have only been provided with an empty string, return early.
if isempty(registerName)
    return;
end

hObject = this.getRegisterDb(registerName);

if isempty(hObject) || isempty(path)
    return;
end

% Remove the unneeded '/'.
path(1) = [];

hObject = getObjectFromPath(hObject, path);

% [EOF]
