function visible_listener(h, eventData)
%VISIBLE_LISTENER is the abstract class's implementation of the enable listener

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 19:17:45 $

% Get the vis state
visState = get(h, 'visible');

if strcmp(visState, 'off')
    set(handles2vector(h), 'visible', 'off');
else
    update_uis(h);
end

% [EOF]
