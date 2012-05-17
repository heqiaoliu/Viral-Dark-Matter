function update_params_on_chart(chartId)

%   Copyright 2009-2010 The MathWorks, Inc.
    
    paramsString = get_params_str_for_chart(chartId);
    instanceId = sf('get',chartId,'chart.instance');
    sfunctionBlock = sf('get',instanceId,'instance.sfunctionBlock');
    safe_set_param(sfunctionBlock,'Parameters',paramsString);
    
end
