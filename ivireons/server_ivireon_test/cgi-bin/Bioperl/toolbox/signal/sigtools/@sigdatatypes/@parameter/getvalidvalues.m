function out = getvalidvalues(hObj, out)
%GETVALIDVALUES Returns the valid values

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/28 19:09:37 $

if iscell(out),
    out     = get(hObj, 'AllOptions');
    do      = get(hObj, 'DisabledOptions');
    out(do) = [];
end

% [EOF]
