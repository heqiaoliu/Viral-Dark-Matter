function newRules = saSupportVariableSizing(obj)
    % Removing 'supportVariableSizing' field from charts when saving in pre-9B format.
    % Copyright 2009-2010 The MathWorks, Inc.
    
    newRules = {};
    
    % No SF machine in a model -- nothing do do.
    machineId = sf('find',sf('MachinesOf'),'machine.name',obj.modelName);
    if isempty(machineId)
        return;
    end
    
    if isR2009aOrEarlier(obj.ver)
        % Stateflow.chart.supportVariableSizing field has been introduced in 9B.
        fieldRule = sl('makeSaveAsRule','supportVariableSizing','','remove');
        chartRule = sl('makeSaveAsRule','Stateflow','','',sl('makeSaveAsRule','chart','','',fieldRule));
        newRules = {chartRule};
    end    
end
