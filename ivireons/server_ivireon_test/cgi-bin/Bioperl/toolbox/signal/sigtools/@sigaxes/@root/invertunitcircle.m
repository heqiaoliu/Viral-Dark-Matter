function varargout = invertunitcircle(hObj)
%INVERTUNITCIRCLE Invert about the unit circle.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:21:11 $

newvalue = conj(1./double(hObj));

if nargout,
    varargout = {newvalue};
else
    setvalue(hObj, newvalue);
end

% [EOF]
