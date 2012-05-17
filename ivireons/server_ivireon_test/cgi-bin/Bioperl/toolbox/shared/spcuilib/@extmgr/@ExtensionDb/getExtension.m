function hExtension = getExtension(this,theType,theName)
%getExtension Return handle to named extension instance.
%  getExtension(hExtensionDb,'ExtType','ExtName') returns handle to named
%  extension instance from database.  If not found, empty is returned.
%
%  getExtension(hExtensionDb,hRegister) specifies theType and theName via the
%  extension registration hRegister.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2007/04/09 19:04:22 $

if nargin == 2 && ischar(theType)
    [theType, theName] = strtok(theType, ':');
    if ~isempty(theName)
        theName(1) = [];
    end
end

if ischar(theType)
    if isempty(theName)
        hExtension = iterator.findImmediateChildren(this, ...
            @(hExtension) isNamed(hExtension.Register, theType));
    else
        hExtension = iterator.findImmediateChild(this, ...
            @(hExtension) isNamed(hExtension.Register, theType, theName));
    end
else
    % hRegister is specified (and not theType string)
    hExtension = findChild(this, 'Register', theType);
end

% [EOF]
