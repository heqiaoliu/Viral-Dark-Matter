function props = getdefaultprops(hObj)
%GETDEFAULTPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:21:04 $

if strcmpi(hObj.Enable, 'On'),
    p = {'Color', 'b'};
else
    p = getdisabledprops(hObj);
end

props = {'LineWidth', 1, 'Marker', 'x', 'MarkerSize', 8, 'LineStyle', 'none', p{:}};

% [EOF]