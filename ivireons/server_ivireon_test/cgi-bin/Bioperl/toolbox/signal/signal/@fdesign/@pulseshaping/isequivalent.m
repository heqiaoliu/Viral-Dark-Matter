function b = isequivalent(this, htest)
%ISEQUIVALENT   True if the object is equivalent.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/04 23:21:15 $

if isa(htest, 'fdesign.pulseshaping'),
    b = isequivalent(this.PulseShapeObj, htest.PulseShapeObj);
else
    b = false;
end

% [EOF]
