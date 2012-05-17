function b = enableparameter(hObj, tag)
%ENABLEPARAMETER Enable the parameter, returns true if the parameter is enabled.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:28:07 $

b = false;

% This should be protected

list = get(hObj, 'DisabledParameters');

if ~isempty(list),
    indx = find(strcmpi(tag, list));
    
    if ~isempty(indx),
        
        list(indx) = [];
        
        set(hObj, 'DisabledParameters', list);
        ed.type = 'Enabled';
        ed.tag  = tag;
        send(hObj, 'DisabledListChanged', ...
            sigdatatypes.sigeventdata(hObj, 'DisabledListChanged', ed));
        b = true;
    end
end

% [EOF]
