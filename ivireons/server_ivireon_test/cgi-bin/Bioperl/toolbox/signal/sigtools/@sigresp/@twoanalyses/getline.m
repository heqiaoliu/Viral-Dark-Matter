function hline = getline(hObj)
%GETLINE Return the handles to the line objects

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:30:13 $

if ishandlefield(hObj, 'cline'),
    h     = get(hObj, 'Handles');
    hline = convert2vector(h.cline);
else
    hline = [];
end

% [EOF]
