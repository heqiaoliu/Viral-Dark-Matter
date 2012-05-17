function do_post_prop_error_checks(machineId, linkMachines)

%   Copyright 2007 The MathWorks, Inc.

sf('Cg', 'do_post_prop_error_checks', machineId);
for i=1:length(linkMachines)
    libMachineId = sf('find', 'all', 'machine.name', linkMachines{i});
    sf('Cg', 'do_post_prop_error_checks', libMachineId);
end