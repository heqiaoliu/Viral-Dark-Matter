function connected = isConnected(this)
%ISCONNECTED True if the object is Connected
%   OUT = ISCONNECTED(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/20 00:20:12 $

if ishandle(get(this,'BlockHandle'))
    connected = true;
else
    connected = false;
end

% [EOF]
