function newRules = saSLFunctions(obj)
    % Save a model containing SL functions in Stateflow in previous
    % versions.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    
    newRules = {};
    
    % Find machine ID
    machineId = sf('find',sf('MachinesOf'),'machine.name',obj.modelName);
    if isempty(machineId)
        return;
    end
    
    r = sfroot;
    machineH = r.idToHandle(machineId);

    if isR2008aOrEarlier(obj.ver)
        % Produce a warning if we attempt to save a model containing SLINSF
        % in versions prior to 8a.
        
        charts = machineH.find('-isa', 'Stateflow.Chart');
        for i=1:length(charts)
            ch = charts(i);
            simf = ch.find('-isa', 'Stateflow.SLFunction');
            if ~isempty(simf)
                simf = simf(1);
                
                fcnRelPath = sf('FullName', simf.Id, simf.Chart.id, '.');
                chartRelPath = sf('FullName', simf.Chart.Id, simf.Machine.Id, '/');
                DAStudio.warning('Stateflow:slinsf:SaveInPrevVersion', fcnRelPath, chartRelPath);
                
                break;
            end
        end
        
    end

    % Even though SL in SF was officially released in 8b, 8a had
    % featured off version of SL in SF which still worked with existing
    % models.
    if isR2007bOrEarlier(obj.ver)
        % Remove Stateflow.state.simulink
        
        rule1 = sl('makeSaveAsRule', 'simulink','','remove');
        rule2 = sl('makeSaveAsRule', 'state', '', '', rule1);
        rmSfStateSim = sl('makeSaveAsRule', 'Stateflow', '', '', rule2);
        
        newRules = {rmSfStateSim};

        % Delete the SL function itself. If a chart containing an SL
        % function call subsystem is opened in 7b-, then the chart cannot
        % be deleted because of all the PreDelete callbacks.
        % g560823
        simFcns = machineH.find('-isa', 'Stateflow.SLFunction');
        for i=1:length(simFcns)
            delete(simFcns(i));
        end
        
        return;
    end
    
    if isR2008bOrEarlier(obj.ver)
        % In order to work in R2008b/8a, we need the Simulink.Subsystem to
        % remember the Stateflow DB_state it is bound to. This is done by
        % putting the SSID of the Stateflow DB_state on the
        % Simulink.Subsystem
        
        simFunctions = machineH.find('-isa', 'Stateflow.SLFunction');
        for i=1:length(simFunctions)
            simf = simFunctions(i);
            subsys = simf.getDialogProxy;
            
            subsys.UserData = simf.SSIdNumber;
            subsys.UserDataPersistent = 'on';
        end
        
        % remove Stateflow.state.simulink.blockName
        
        rule1 = sl('makeSaveAsRule', 'blockName','','remove');
        rule2 = sl('makeSaveAsRule', 'simulink', '', '', rule1);
        rule3 = sl('makeSaveAsRule', 'state', '', '', rule2);
        rmSfStateSimBlockName = sl('makeSaveAsRule', 'Stateflow', '', '', rule3);
        
        newRules = {rmSfStateSimBlockName};
    end
    
end
