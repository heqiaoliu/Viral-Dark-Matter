function result = truth_table_chart_man(methodName, objectId, varargin)
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/12/01 08:08:32 $

result = [];

% Input object must be truthtable chart
if ~sf('ishandle',objectId) || ~is_truth_table_chart(objectId)
    return;
end

try
    switch(methodName)
        case {'create_ui', ...
              'update_data', ...
              'update_active_instance', ...
              'goto_sf_editor', ...
              'goto_sf_explorer'}
            result = feval(methodName, objectId);
        case {'highlight', ...
              'add_data', ...
              'add_event'}
            result = feval(methodName, objectId, varargin{:});
        otherwise
            fprintf(1,'Unknown methodName %s passed to truth_table_chart_man', methodName);
    end
catch ME
    str = sprintf('Error calling truth_table_chart_man(%s): %s',methodName,ME.message);
    construct_error(objectId, 'Truth Table', str, 0);
    slsfnagctlr('ViewNaglog');
end

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following functions are for truthtable chart block     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = get_function_from_chart(chartId)
fcnIds = truth_tables_in(chartId);
f = [];
if ~isempty(fcnIds)
  f = fcnIds(1);
end
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    truth_table_function_man('create_ui', result);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    truth_table_function_man('update_data', result);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = highlight(chartId, varargin)

result = get_function_from_chart(chartId);
if ~isempty(result)
    truth_table_function_man('highlight', result, varargin{:});
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(chartId)

result = get_function_from_chart(chartId);
if ~isempty(result)
    truth_table_function_man('update_active_instance', result);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_explorer(chartId)

result = sf_de_manager('open', chartId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = add_data(objectId, scope, showDialog)

result = [];

if nargin < 3
    showDialog = false;
end

hObj = idToHandle(sfroot, objectId);
d = Stateflow.Data(hObj);
d.Scope = scope;

if showDialog
    sfdlg(d.id, 1);
end

return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = add_event(objectId, scope, showDialog)

result = [];

if nargin < 3
    showDialog = false;
end

hObj = idToHandle(sfroot, objectId);

switch lower(scope)
    case 'input'
        e = Stateflow.Trigger(hObj);
    case 'output'
        e = Stateflow.FunctionCall(hObj);
    otherwise
        return;
end

if showDialog
    sfdlg(e.id, 1);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_editor(objectId)

result = [];
sf('UpView', objectId);
return;
    