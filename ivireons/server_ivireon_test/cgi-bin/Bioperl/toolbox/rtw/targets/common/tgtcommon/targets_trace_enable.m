function targets_trace_enable(model)
% TARGETS_TRACE_ENABLE: Enable the Traceability feature for the model.

% Copyright 2006-2007 The MathWorks, Inc.

% see if "model" is a configuration set or a model
switch class(model)
    case 'char'
        % ensure a root model name
        model = strtok(model, '/');
        names = getConfigSets(model);
        for i=1:length(names)
           % process each config set
           cs = getConfigSet(model, names{i});
           i_processConfigSet(cs);    
        end
    case 'Simulink.ConfigSet'
        % set the config set
        cs = model;
        i_processConfigSet(cs);
    otherwise
      TargetCommon.ProductInfo.error('common', 'InputArgNInvalid', 'Input', 'Simulink model or configuration set.');
end


function i_processConfigSet(cs)
if strcmpi(get_param(cs, 'IsERTTarget'), 'on')
    trace_params = targets_get_trace_parameters();
    for k = 1:length(trace_params)
        set_param(cs, trace_params{k}, 'on');
    end
end
