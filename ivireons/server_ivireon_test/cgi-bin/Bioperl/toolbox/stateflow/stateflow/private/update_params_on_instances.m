function update_params_on_instances(machineId, loading)
% This function synchronizes
% the parameter strings of the sfunction block
% underneath the chart mask. For every data that belongs to
% the chart and is initialized from workspace, we
% create a parameter on the sfunction block.
% this is a prerequisite for a lot of things
% such as code reuse fixes, hierarchical scoping
% of chart constants, tunable params etc.
% the params strings on the sfunction block are
% thus synced just before codegen and also at 
% model load time from MachinePostLoad in sf.dll

% Copyright 2002-2009 The MathWorks, Inc.


modelH = sf('get',machineId,'machine.simulinkModel');

relock = strcmpi(get_param(modelH, 'lock'), 'on');
if(relock)
    set_param(modelH,'lock','off');
end
dirtyStatus = get_param(modelH,'dirty');

charts = sf('get',machineId,'machine.charts');

for i=1:length(charts)
    chartId = charts(i); 
    update_params_on_chart(chartId);
    
    if ~loading
        % Since 2007b, Stateflow blocks always have 'ExplicitOnly' hierarchical resolution.
        blockH = chart2block(chartId);
        safe_set_param(blockH, 'PermitHierarchicalResolution', 'ExplicitOnly');
    end
end

safe_set_param(modelH,'dirty',dirtyStatus);
if(relock)
    set_param(modelH,'lock','on');
end

    
