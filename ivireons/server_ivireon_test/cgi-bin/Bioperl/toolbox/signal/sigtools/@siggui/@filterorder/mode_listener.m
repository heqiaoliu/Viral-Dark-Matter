function mode_listener(h, eventData)
%MODE_LISTENER Callback for listener to the mode property.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/13 00:23:26 $

% This method should be private

% Determine if the mode is set to minimum
Mode = get(h,'Mode');
AllModes = set(h, 'Mode');
Vals = strcmp(AllModes, Mode);

% Get the handles to the radio buttons
handles = get(h, 'handles');
rbs = handles.rbs;

% Set the radio buttons to match the values of the mode property
for i = 1:length(AllModes)
    set(rbs(i),'value', Vals(i))
end

% Set the enable state of the edit box as appropriate
if strcmp(get(h, 'enable'),'on')
    if strcmp(Mode, AllModes{2})
        setenableprop(handles.eb, 'off', false);
    else
        setenableprop(handles.eb, 'on', false);
    end
end

% [EOF]
