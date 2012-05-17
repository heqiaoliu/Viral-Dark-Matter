function setorder(h, orderStr)
%SETORDER Set the length of the filter

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:23:33 $

try,
    order = evaluatevars(orderStr);
    set(h.privWindow, 'Length', order);
catch
    warning(h, 'Invalid variable.  Using previously set length.');
end

% [EOF]
