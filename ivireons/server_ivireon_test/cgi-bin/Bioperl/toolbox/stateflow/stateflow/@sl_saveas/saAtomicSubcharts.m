function newRules = saAtomicSubcharts(obj)
    % Save a model containing atomic subcharts in Stateflow in previous
    % versions.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    
    newRules = {};
    
    % Find machine ID
    machineId = sf('find',sf('MachinesOf'),'machine.name',obj.modelName);
    if isempty(machineId)
        return;
    end
    
    r = sfroot;
    machineH = r.idToHandle(machineId);

    if isR2010aOrEarlier(obj.ver)
        
        charts = machineH.find('-isa', 'Stateflow.Chart');
        for i=1:length(charts)
            ch = charts(i);
            subcharts = ch.find('-isa', 'Stateflow.AtomicSubchart');

            for j=1:length(subcharts)
                subchart = subcharts(j);

                relPath = sf('FullName', subchart.Id, subchart.Chart.id, '.');
                chartRelPath = sf('FullName', subchart.Chart.Id, subchart.Machine.Id, '/');
                DAStudio.warning('Stateflow:subchart:SaveInPrevVersion', relPath, chartRelPath);

                delete(subchart);
            end
        end
        
    end
    
end
