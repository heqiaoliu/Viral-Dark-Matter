function prop = getpositionproperty(this, c)
%GETPOSITIONPROPERTY   Get the positionproperty.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:01:25 $

if ishghandle(c, 'axes')
    prop = 'OuterPosition';
else
    prop = 'Position';
end

% [EOF]
