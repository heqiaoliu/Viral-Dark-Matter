function hPropertyDb = getPropertyDb(this)
%GETPROPERTYDB Get the propertyDb.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:10:01 $

hPropertyDb = get(this, 'PropertyDb');
if isempty(hPropertyDb)
    hPropertyDb = feval(this, 'getPropertyDb');
    set(allChild(hPropertyDb), 'Status', 'default');
    set(this, 'PropertyDb', hPropertyDb)
end

% [EOF]
