function b = ishandlefield(hObj, field)
%ISHANDLEFIELD Returns true if the field is a handle

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2009/01/05 18:01:08 $

h = get(hObj, 'Handles');

if isfield(h, field)
    h = convert2vector(h.(field));

    if all(ishghandle(h))
        b = true;
    else
        b = false;
    end
else
    b = false;
end

% [EOF]
