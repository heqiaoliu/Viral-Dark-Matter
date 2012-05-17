function mode_listener(h, eventData)
%MODE_LISTENER Callback for listener to the mode property.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:27:36 $

% This method should be private

handles = get(h, 'handles');

% Determine if the mode is set to minimum
Mode = get(h,'Mode');
AllModes = set(h, 'Mode');
Vals = strcmp(AllModes, Mode);

indx = find(Vals);
if indx ~= 1,
    set(handles.pop, 'Value', indx-1);
end

Vals = [Vals(1) any(Vals(2:4))];

% Set the radio buttons to match the values of the mode property
for i = 1:length(Vals)
    set(handles.rbs(i),'value', Vals(i))
end

% Set the enable state of the edit box as appropriate
if ~strcmp(Mode, AllModes{1})
    setenableprop(handles.eb, 'off');
else
    setenableprop([handles.eb handles.pop], h.Enable);
end

% [EOF]
