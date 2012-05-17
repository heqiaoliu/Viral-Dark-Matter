function update_states_when_enabling(chartId)

%   Copyright 2009 The MathWorks, Inc.

    chartBlockH = chart2block(chartId);
    triggerPortH = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'TriggerPort');
    if isempty(triggerPortH)
        return
    end
    
    chartUddH = idToHandle(sfroot, chartId);
    statesWhenEnabling = chartUddH.StatesWhenEnabling;
    set_param(triggerPortH, 'StatesWhenEnabling', statesWhenEnabling);
end