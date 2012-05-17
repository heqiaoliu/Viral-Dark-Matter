function b = disableparameter(hObj, tag)
%DISABLEPARAMETER Disable the parameter, returns true if the parameter is disabled.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:28:06 $

% This should be protected

b = false;

list = get(hObj, 'DisabledParameters');

if ~any(strcmpi(tag, list)),
    
    list = {list{:}, tag};
    set(hObj, 'DisabledParameters', list);

    % Build up the custom event data so they listener can be more efficient.
    ed.type = 'Disabled';
    ed.tag  = tag;

    send(hObj, 'DisabledListChanged', ...
        sigdatatypes.sigeventdata(hObj, 'DisabledListChanged', ed));
    b = true;
end

% [EOF]
