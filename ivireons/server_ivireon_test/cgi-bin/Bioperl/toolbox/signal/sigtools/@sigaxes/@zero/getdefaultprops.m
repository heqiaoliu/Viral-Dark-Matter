function props = getdefaultprops(hObj)
%GETDEFAULTOPTS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:21:15 $

if strcmpi(hObj.Enable, 'On'),
    p = {'Color', 'b'};
else
    p = getdisabledprops(hObj);
end

props = {'LineWidth', 1, 'Marker', 'o', 'MarkerSize', 7, 'LineStyle', 'none', p{:}};

% [EOF]