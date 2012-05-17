function autoupdate_listener(h, eventData)
%AUTOUPDATE_LISTENER updates the object to update freq values

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:13:11 $

state = get(eventData, 'NewValue');

hndls = get(h,'handles');
handle = hndls.checkbox;

switch state
case 'on'
    set(handle,'value',1)
case 'off'
    set(handle,'value',0)
end

% [EOF]
