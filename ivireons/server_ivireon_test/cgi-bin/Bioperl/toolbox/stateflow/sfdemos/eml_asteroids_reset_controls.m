function eml_asteroids_reset_controls(x)

% Copyright 2005 The MathWorks, Inc.

if x
    set_param([bdroot '/StopTurn'], 'Value', '0');
    set_param([bdroot '/Turn'], 'Value', '0');
    set_param([bdroot '/Thrust'], 'Value', '0');
    set_param([bdroot '/Shoot'], 'Value', '0');
end
