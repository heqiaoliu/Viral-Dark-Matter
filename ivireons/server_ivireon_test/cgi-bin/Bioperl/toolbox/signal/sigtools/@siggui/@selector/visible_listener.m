function visible_listener(hObj, varargin)
%VISIBLE_LISTENER   Listener to the Visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/06/03 16:16:17 $

sigcontainer_visible_listener(hObj, varargin{:});

h = get(hObj, 'Handles');
strs = get(hObj, 'Strings');

for indx = 1:length(strs)
    if iscell(strs{indx}),
        set(h.popup(indx), 'Visible', hObj.Visible);
    else
        set(h.popup(indx), 'Visible', 'Off');
    end
end

% [EOF]
