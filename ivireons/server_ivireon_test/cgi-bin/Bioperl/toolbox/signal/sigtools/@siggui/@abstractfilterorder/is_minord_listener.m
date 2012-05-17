function is_minord_listener(h, eventData)
%IS_MINORD_LISTENER Callback executed by listener to the isMinOrd property.

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/03/13 19:50:24 $

% This method should be private

% Get the handles to the radio buttons
handles = get(h, 'handles');
rbs = handles.rbs;

% Set the enable state
if h.isMinOrd
    setenableprop([rbs(end) handles.pop], h.Enable);
else
    setenableprop([rbs(end) handles.pop], 'off');
end

% [EOF]
