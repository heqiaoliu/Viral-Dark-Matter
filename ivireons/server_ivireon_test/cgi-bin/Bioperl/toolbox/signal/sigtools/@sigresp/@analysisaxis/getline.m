function hline = getline(hObj)
%GETLINE Returns the line handles

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:26 $

if ishandlefield(hObj, 'line'),
    h     = get(hObj, 'Handles');
    hline = h.line;
else
    hline = [];
end

% [EOF]
