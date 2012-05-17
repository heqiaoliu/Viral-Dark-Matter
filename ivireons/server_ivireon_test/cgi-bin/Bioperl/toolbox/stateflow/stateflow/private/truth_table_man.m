function result = truth_table_man(methodName, varargin)
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.6.2.12 $  $Date: 2008/12/01 08:08:35 $

result = [];

try
    switch (methodName)
        case {'help',...
              'stateflow_help',...
              'about_stateflow',...
              'new_model',...
              'open_model',...
              'help_desk',...
              'construct_initial_predicate_table',...
              'construct_initial_action_table'}
            result = feval(methodName);
        case {'add_data',...
              'add_event',...
              'goto_sf_editor',...
              'goto_sf_explorer'}
            varargin{1} = truth_table_fcn_source(varargin{1});
            result = dispatch_task(methodName, varargin{:});
        otherwise
            result = dispatch_task(methodName, varargin{:});
    end
catch ME
    str = sprintf('Error calling truth_table_man(%s): %s',methodName,ME.message);
    construct_error([], 'Truth Table', str, 0);
    slsfnagctlr('ViewNaglog');
end

return;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = dispatch_task(methodName, objectId, varargin)

result = [];

if ~sf('ishandle', objectId)
    return;
end

if is_truth_table_fcn(objectId)
    result = truth_table_function_man(methodName, objectId, varargin{:});
elseif is_truth_table_chart(objectId)
    result = truth_table_chart_man(methodName, objectId, varargin{:});
else
    fprintf(1,'Non-TruthTable object with id #%d passed to truth_table_man', objectId);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help
result = [];
sfhelp('truth_tables_chapter');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = new_model
result = [];
sfnew;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_model
result = [];
sfopen;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = stateflow_help
result = [];
sfhelp('stateflow');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_desk
result = [];
sfhelp('helpdesk');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = about_stateflow
result = [];
sfabout;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initPredTbl = construct_initial_predicate_table

initPredTbl(1:2, 1:3) = {''};
initPredTbl{2,2} = 'Actions';
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initActTbl = construct_initial_action_table

initActTbl(1, 1:2) = {''};
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectId = truth_table_fcn_source(objectId)

if ~is_truth_table_chart(objectId)
    % must be truth table function
    chartId = sf('get', objectId, '.chart');
    if is_truth_table_chart(chartId)
        objectId = chartId;
    end
end

return;
