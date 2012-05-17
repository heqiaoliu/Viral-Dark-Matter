function machineId = acquire_or_create_machine_for_model(newModelH)

% Either the new model has a machine or not 
newMachineId = sf('find', 'all', 'machine.simulinkModel', newModelH);
if model_is_a_library(newModelH),
    dstIsALibrary = 1;  
else
    dstIsALibrary = 0;  
end;

switch(length(newMachineId)),
    case 0,        newMachineId = sf('new', 'machine', '.name', get_param(newModelH, 'name'), '.simulinkModel', newModelH, '.isLibrary', dstIsALibrary);
    case 1,
    otherwise,
        disp('Multiple machines found for this model, picking first one.');
        newMachineId = newMachineId(1);
end;

% If this machine was deleted, undelete it
if sf('get', newMachineId, '.deleted'),
    sf('set', newMachineId, '.deleted', 0); 
end;
machineId = newMachineId;

