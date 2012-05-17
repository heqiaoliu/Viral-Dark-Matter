function perform_model_reference_error_checks(modelName)

mdlrefInfo = get_model_reference_info(modelName);
if(~mdlrefInfo.isMultiInst) 
    return;
end

machineId = sf('find',sf('MachinesOf'),'machine.name',modelName);
exportedFcnInfo = sf('get',machineId,'machine.exportedFcnInfo');

if(~isempty(exportedFcnInfo))
    sf('Private','construct_error',machineId,'Coder',mdlrefInfo.err,true);    
end

error_check_machine_data_events(machineId,mdlrefInfo.err);
linkMachines = get_link_machine_list(machineId, 'sfun');
for i = 1:length(linkMachines)
    linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
    error_check_machine_data_events(linkMachine,mdlrefInfo.err);
end


function error_check_machine_data_events(machineId,msg)

if(~isempty(sf('find',sf('DataOf',machineId),'~.scope','CONSTANT_DATA')) || ~isempty(sf('EventsOf',machineId)))
    sf('Private','construct_error',machineId,'Coder',msg,true);
end

function mdlrefInfo = get_model_reference_info(modelName) 
   mdlrefInfo.isMultiInst = 0;
   mdlrefInfo.err = '';

   mdlTarget = get_param(modelName,'ModelReferenceTargetType');
   if(strcmpi(mdlTarget, 'NONE') ~= 1 )
     %% Model reference SIM or RTW target	
     numInstAllowed = get_param(modelName, ...
   				    'ModelReferenceNumInstancesAllowed');
     mdlrefInfo.isMultiInst = strcmp(numInstAllowed, 'Multi') == 1;
     mdlrefInfo.err = ['Cannot generate reusable model '            ...
   	'reference target in the presence of machine parented data, events or ' ...
   	'exported graphical functions. Consider updating the "Total number of instances '     ...
   	'allowed per top model" parameter, in the Model Referencing '   ...
   	'tab of Simulation parameters (Configuration) dialog, to "One".'];	
   end