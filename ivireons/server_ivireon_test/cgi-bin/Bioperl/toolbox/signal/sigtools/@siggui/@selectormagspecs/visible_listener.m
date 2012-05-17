function visible_listener(h, eventData)
%VISIBLE_LISTENER  Listen to the visible state of the object

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:02:25 $

% Determine the visible state
visState = get(h, 'Visible');

% Set the visibility of all uicontrols
set(handles2vector(h), 'Visible', visState);

% If the state was set to on update the uicontrols
if strcmpi(visState, 'on');
    update_uis(h);
end

% [EOF]
