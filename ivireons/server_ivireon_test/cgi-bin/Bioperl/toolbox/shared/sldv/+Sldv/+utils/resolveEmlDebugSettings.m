function f = resolveEmlDebugSettings(modelH)    

%   Copyright 2009 The MathWorks, Inc.

    f = {};
    sfrt = sfroot;
    machine = sfrt.find('-isa','Stateflow.Machine','name',get_param(modelH,'Name'));
    if ~isempty(machine)                        
        emlblks = machine.find('-isa', 'Stateflow.EMChart');
        for idx = 1:length(emlblks)
            f{end+1} = {'sf', 'set', emlblks(idx).Id,'chart.eml.noDebugging', 0}; %#ok
        end
    end       
end