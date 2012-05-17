function busName = get_input_bus_name(path, inputIdx)

%   Copyright 2010 The MathWorks, Inc.

    ph = get_param(path, 'porthandles');
    hh = get_param(ph.Inport(inputIdx+1), 'SignalHierarchy');
    busName = hh.BusObject;
end
