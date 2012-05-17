function status = machine_in_modelref_normal_mode_sim(machineId)
modelName = sf('get',machineId,'machine.name');
status = strcmpi(get_param(modelName,'ModelReferenceTargetType'),'SIM');
