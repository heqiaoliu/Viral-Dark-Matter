function clear_simstruct_in_machine(machineId)

%   Copyright 2007 The MathWorks, Inc.

sf('Cg','clear_all_chart_active_simstruct_in_machine',machineId);
linkMachines = get_link_machine_list(machineId, 'sfun');
for i = 1:length(linkMachines)
    linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
    sf('Cg', 'clear_all_chart_active_simstruct_in_machine',linkMachine);
end
