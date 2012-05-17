function connected = isConnected(this)
%ISCONNECTED True if the object is Connected
%   OUT = ISCONNECTED(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:05 $

if ishandle(get(this,'BlockHandle'))
    connected = true;
else
    connected = false;
end
end