function fig = eml_asteroids_setup

% Copyright 2005 The MathWorks, Inc.

    fig = figure('KeyPressFcn',@keypress_fn,'DeleteFcn',@delete_fn);
    set(fig, 'DoubleBuffer', 'on', 'Tag', 'asteroids_fig');
    
function delete_fn(src,ev)
    s = slroot;
    m = s.find('-regexp','name','eml_asteroids');
    if ~isempty(m)
        sm = m(2);
        set_param(sm.Name,'SimulationCommand','stop');
    end
        
function keypress_fn(src,ev)
    keycode = double(ev.Character);
    turn = 0;
    if keycode == 28 || ev.Character == 'g'
        set_param([bdroot '/Turn'], 'Value', '1');
    elseif keycode == 29 || ev.Character == 'j'
        set_param([bdroot '/Turn'], 'Value', '-1');
    else
        set_param([bdroot '/Turn'], 'Value', '0');
    end
    if keycode == 31 || ev.Character == 'g'
        set_param([bdroot '/StopTurn'], 'Value', '1');
    end
    if keycode == 30 || ev.Character == 'y'
        set_param([bdroot '/Thrust'], 'Value', '1');
    else
        set_param([bdroot '/Thrust'], 'Value', '0');
    end
    if keycode == 32 || ev.Character == ' '
        set_param([bdroot '/Shoot'], 'Value', '1');
    end
    