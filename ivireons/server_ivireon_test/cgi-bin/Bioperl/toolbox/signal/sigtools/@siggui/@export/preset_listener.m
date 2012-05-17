function preset_listener(hXP, eventData)
%PRESET_LISTENER Resizes the Dialog when necessary

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:23:10 $

% This is a WhenRenderedListener

% Get the length of the new property.
count = length(eventData.newvalue);

if strcmpi(get(eventData.Source, 'Description'), 'Object'),
    count = max([count length(hXP.Variables)]);
else
    count = max([count length(hXP.Objects)]);
end

% If the length of the new property is not equal to the old variable count, resize
if count ~= get(hXP,'VariableCount'),
    set(hXP, 'VariableCount', count);
    resize(hXP);
end

% [EOF]
