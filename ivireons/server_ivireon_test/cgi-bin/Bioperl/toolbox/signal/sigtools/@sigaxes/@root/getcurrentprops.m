function props = getcurrentprops(hObj)
%GETCURRENTPROPS Returns the props to set when the root is current.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:21:08 $

props = getdefaultprops(hObj);

if strcmpi(hObj.Enable, 'On'),
    p = {'Color', 'g'};
else
    p = getdisabledprops(hObj);
end

props = {props{:}, 'LineWidth', 2, 'MarkerSize', 10, p{:}};

% [EOF]
