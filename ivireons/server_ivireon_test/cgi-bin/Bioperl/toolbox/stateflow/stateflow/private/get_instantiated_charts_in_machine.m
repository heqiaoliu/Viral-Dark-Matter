function chartIds = get_instantiated_charts_in_machine(machineId)

% Copyright 2004 The MathWorks, Inc.

    chartIds = sf('find',sf('get',machineId,'machine.charts'),'chart.isInstantiated',1);