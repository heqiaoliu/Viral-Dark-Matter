function cs = targets_getActiveConfigSet(model)
% TARGETS_GETACTIVECONFIGSET - Given a model name, returns the active
% configuration set. Given a configuration set, returns the configuration 
% set unmodified. This is a helper function used to allow other functions
% to accept either a model name or a configuration set as an input
% argument.
%
% cs = targets_getActiveConfigSet(model)
%
% cs - The configuration set.
% model - The model name or configuration set.

%   Copyright 2006-2009 The MathWorks, Inc.

% see if "model" is a configuration set or a model
switch class(model)
    case 'char'
        % ensure a root model name
        model = strtok(model, '/');
        % attempt to load the root model
        load_system(model);
        % get the config set
        cs = getActiveConfigSet(model);
    case 'Simulink.ConfigSet'
        % set the config set
        cs = model;
  otherwise
    rtw.pil.ProductInfo.error('pil', 'InputArgNInvalid', 'Input', 'Simulink model or configuration set');

end
