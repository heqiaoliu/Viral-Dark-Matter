function value = getsettings(hPrm, eventData)
%GETSETTINGS Get the value from the eventdata

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/30 18:14:15 $

if ~isempty(eventData) & strcmpi(get(eventData, 'Type'), 'UserModified'),
    value = get(eventData, 'Data');
else
    value = get(hPrm, 'Value');
end

% [EOF]
