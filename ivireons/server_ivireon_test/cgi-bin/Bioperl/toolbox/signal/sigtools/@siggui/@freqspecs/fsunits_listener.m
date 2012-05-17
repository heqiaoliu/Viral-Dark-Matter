function fsunits_listener(h, eventData);
%FSUNITS_LISTENER Listens to the fsspecifier units property for autoupdating

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:25:02 $

if strcmpi(get(eventData, 'NewValue'), 'normalized (0 to 1)'),
    fc = 'w';
else
    fc = 'F';
end

lbls = get(h, 'Labels');

for i = 1:length(lbls),
    lbls{i}(1) = fc;
end

set(h, 'Labels', lbls);

% Only do this if auto updating is turned on
if strcmpi(get(h, 'autoupdate'), 'on')
    
    fsh = getcomponent(h, 'siggui.specsfsspecifier');
    % fsh = get(h,'fshandle');

    % Determine the sampling frequency
    fs = get(fsh, 'value');
    
    % Get the original, new and all valid units
    origin = get(fsh, 'units');
    target = get(eventData, 'NewValue');
    allUnits = set(fsh, 'units');
    
    % Get the specification values
    values = get(h,'values');
    
    % Convert the values
    newvalues = convertfrequnits(values, fs, origin, target, allUnits);
   
    % Set the new values
    set(h, 'values', newvalues);
    
end

% [EOF]
