function clear_current_system_selection

% Copyright 2005 The MathWorks, Inc.

h = find_system(gcs, 'FindAll', 'on', 'Selected', 'on');

% vector set does not work
for i=1:length(h)
    set_param(h(i), 'Selected', 'off');
end