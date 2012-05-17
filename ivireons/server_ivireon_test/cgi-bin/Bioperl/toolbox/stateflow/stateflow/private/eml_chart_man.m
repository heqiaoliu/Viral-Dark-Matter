function result = eml_chart_man(methodName, objectId, varargin)
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/05/20 03:35:58 $

result = [];

% Input object must be eML based chart
if ~sf('ishandle',objectId) || ~is_eml_based_chart(objectId)
    return;
end

try
    switch(methodName)
        case {'update_active_instance', 'create_ui', 'get_eml_prototype', ...
              'update_data', 'edit_data_ports', 'goto_sf_editor'}
            result = feval(methodName, objectId);
        case {'sync_prototype', 'set_blk_handle'}
            result = feval(methodName, objectId, varargin{:});
        otherwise
            fprintf(1,'Unknown methodName %s passed to eml_chart_man', methodName);
    end
catch ME
    str = sprintf('Error calling eml_chart_man(%s): %s',methodName,ME.message);
    construct_error(objectId, 'Embedded MATLAB', str, 0);
    slsfnagctlr('ViewNaglog');
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following functions are for eML chart block            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_blk_handle(chartId, blockH)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('set_blk_handle', result, blockH);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sync_prototype(chartId, varargin)

result = [];
eMLId = eml_based_fcns_in(chartId);
if isempty(eMLId)
    return;
end

objectId = eMLId(1);
newPrototypeStr = '';
stylingBySeq = 0;

if (nargin > 1)
    % The sync direction is from chart IO to eML script
    % Make sure Stateflow get updated eML script from eML editor.
    eml_function_man('update_data', objectId);

    newPrototypeStr = varargin{1};
    
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str', script);
else
    % The sync direction is from eML script to chart IO
    stylingBySeq = 1;
    
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str', script);
    if ~isempty(pStr)
        % Reconcile only when valid prototype is present in script
        [funcName,inData,outData,obsData] = reconcile_function_io(chartId);
        sf('set', chartId, 'chart.eml.name', funcName); % Cache the function name as eML chart name
    end
    newPrototypeStr = sf('ChartPrototype', chartId);
end

if isempty(pStr)
    % Fix function prototype in script
    eml_function_man('update_script_prototype', objectId, script, ['function ' newPrototypeStr 10], st,en);
elseif ~function_prototype_utils('compare', newPrototypeStr, pStr)
    % Update function prototype in script
    newPrototypeStr = function_prototype_utils('style', newPrototypeStr, pStr, stylingBySeq);
    eml_function_man('update_script_prototype', objectId, script, ['function ' newPrototypeStr], st,en);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = get_function_from_chart(chartId)
fcnIds = eml_based_fcns_in(chartId);
f = [];
if ~isempty(fcnIds)
  f = fcnIds(1);
end
  
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('create_ui', result);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('update_active_instance', result);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_eml_prototype(chartId)

result = [];
emlFunc = eml_based_fcns_in(chartId);
if(~isempty(emlFunc))
    result = eml_function_man('get_eml_prototype', emlFunc(1));
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    eml_function_man('update_data', result);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = edit_data_ports(chartId)

result = sf_de_manager('open', chartId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_editor(objectId)

result = [];
sf('UpView', objectId);
return;
