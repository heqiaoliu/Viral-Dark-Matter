function sync_on_precompile_and_presave(machineId, isSimulating, slModelName)

%   Copyright 2010 The MathWorks, Inc.
    
    if nargin < 3
        % model name and machine name could be different during save as.
        slModelName = sf('get',machineId,'machine.name');
    end
    
    update_eml_data(machineId);         % Update data from all opening eML editors
    sync_script_data();                 % sync data for all scripts
    
    % Update data from all opening truthtable editors
    update_truthtable_data(machineId);  
    update_truth_tables(machineId, ~isSimulating, slModelName);
    
    % Use the direct Stateflow.SLINSF call instead of going through
    % simfcn_man so we do not pollute the command window upon expected
    % user errors.
    Stateflow.SLINSF.SimulinkMan.syncMachinePrototypes(machineId, isSimulating);  % Sync from Simulink functions
    
    % G205007. sync params str after eml did its part.
    update_params_on_instances(machineId, false);
end