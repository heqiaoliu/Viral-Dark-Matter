function errorCount = create_truth_table_eml_script(fcnId)
%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2009/02/18 02:32:23 $

errorCount = 0;
construct_tt_error('reset');

try
    try_create_truth_table_eml_script(fcnId);
catch ME
    construct_tt_error('add', fcnId, ME.message, 0); % this means we hit an unexpected error
end

errorCount = construct_tt_error('get');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function try_create_truth_table_eml_script(fcnId)

[errorCount, table] = process_and_error_check_truth_table(fcnId);

% Early return if there have been earlier errors
if errorCount > 0
    return;
end

clean_up_truth_table_content(fcnId);

% Translate truth table to eml script and set it with fcn object
[script mapping] = truth_table_to_eml(table);
sf('set', fcnId, 'state.eml.script', script);
sf('set', fcnId, 'state.autogen.mapping', mapping);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [script, mapping] = truth_table_to_eml(table)

compose_eml_script('reset');

% Dump truth table main function prototype
compose_eml_script('append', get_prototype(table));

[nP nD] = size(table.predBody);

% the INIT action call
if table.initActIdx > 0
    compose_eml_script('newline');
    dump_action_call(table.initActIdx, table);
end

% Inititalize condition vars
if nP > 0
    compose_eml_script('newline');
    dump_init_condition_vars(table);
end

% dump code to calculate predicate values
for i = 1:nP
    compose_eml_script('newline');
    dump_condition_code(i, table);
end

% Create flag word if the feature is desired
if nP > 0 && table.useFlags
    compose_eml_script('newline');
    dump_eval_flag_word(table);
end

% Only dump "decision" body when predicate table is not empty
if ~isempty(table.predBody)
    compose_eml_script('newline');
    
    % Special case: only 1 decision with all don't cares
    if table.hasDefault && nD == 1
        dump_decision_action_calls(1, table);
    else
        % Dump decision and action calls
        for i = 1:nD
            if i == 1
                keyword = 'if';
            elseif ~table.hasDefault || i ~= nD
                keyword = 'elseif';
            else
                keyword = 'else';
            end
            
            dump_decision_code(i, table, keyword);
            dump_decision_action_calls(i, table, 1);
        end
        
        compose_eml_script('append', 'end');
    end
end

% the FINAL action call
if table.finalActIdx > 0
    compose_eml_script('newline');
    dump_action_call(table.finalActIdx, table);
end

% dump nested action functions
nA = length(table.actionFcn);
for i = 1:nA
    compose_eml_script('newline');
    dump_action_function(i, table);
end

[script mapping] = compose_eml_script('finish');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [script, mapping] = compose_eml_script(method, varargin)
% compose_eml_script('reset')
% compose_eml_script('newline');
% [script, mapping] = compose_eml_script('finish');
% compose_eml_script('append', aTxt, ttMap, indentation);

script = '';
mapping = {};

persistent text;
persistent map;
persistent nLine;
persistent lastMap;

if isempty(text)
    text = '';
    map = {};
    lastMap = [];
    nLine = 0;
end

switch method
    case 'reset'
        text = '';
        map = {};
        lastMap = [];
        nLine = 0;
    case 'append'
        aTxt = varargin{1};
        
        ttMap = [];
        if nargin  > 2
            ttMap = varargin{2};
        end
        
        if ~isequal(ttMap, lastMap)
            lastMap = ttMap;
            map = [map; {nLine + 1, ttMap}];
        end
        
        % Indentation
        indent = 0;
        if nargin > 3
            indent = varargin{3};
        end
        if indent > 0
            indentStr = '';
            for i = 1:indent
                indentStr = [indentStr '    '];
            end
            aTxt = [indentStr regexprep(aTxt, '(\n\r|\n)', ['\n' indentStr])];
        end
        
        text = sprintf('%s%s\n', text, aTxt);
        nLine = nLine + length(find(aTxt == 10)) + 1;
    case 'newline'
        text = sprintf('%s\n', text);
        nLine = nLine + 1;
        
        if ~isempty(lastMap)
            lastMap = [];
            map = [map; {nLine, []}];
        end
    case 'finish'
        map = [map; {nLine+1, []}]; % Mark the end of script
        script = text;
        mapping = map;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_decision_action_calls(decIdx, table, indent)

if nargin < 3
    indent = 0;
end

actions = table.predAction{decIdx};

for i = 1:length(actions)
    dump_action_call(actions(i), table, indent);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_action_call(actIdx, table, indent)

if nargin < 3
    indent = 0;
end

str = [table.actionFcn{actIdx} '();'];
map = create_autogen_map('action', actIdx);
compose_eml_script('append', str, map, indent);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_action_function(actIdx, table)

actionFcn = table.actionFcn;
actionDesp = table.actions{actIdx, table.idxActDesp};
actionCode = table.actions{actIdx, table.idxActCode};
actionLabel = table.actions{actIdx, table.idxActLabel};

str = sprintf('function %s()\n', actionFcn{actIdx});

if ~isempty(actionDesp)
    % insert action description as comments
    str = sprintf('%s\n%% %s', str, regexprep(actionDesp, '(\n\r|\n)', '\n% '));
end

compose_eml_script('append', str);

if ~isempty(actionCode)
    compose_eml_script('newline');
    map = create_autogen_map('action', actIdx);
    compose_eml_script('append', actionCode, map);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_condition_code(predIdx, table)

predDesp = table.predHeader{predIdx, table.idxPredDesp};
predLabel = table.predHeader{predIdx, table.idxPredLabel};
predCode = table.predHeader{predIdx, table.idxPredCode};
predVar = table.predVar{predIdx};

str = '';
if ~isempty(predDesp)
    % insert predicate description as comments
    str = sprintf('%% %s\n', regexprep(predDesp, '(\n\r|\n)', '\n% '));
end

% Extract out comments from predicate code
cstr = regexp(predCode, '%[^\n]*(\n|$)', 'match');
if ~isempty(cstr)
    cstr = regexprep([cstr{:}], '^\s*(.*?)\s*$', '$1');
    str = sprintf('%s%s\n', str, cstr);
end

compose_eml_script('append', str);

% Remove comments
predCode = regexprep(predCode, '%[^\n]*(\n|$)', '$1');
% Flatten out line continuation
predCode = regexprep(predCode, '(^|[^\.])\.\.\.\s*(\n|$)', '$1 ');
% Flatten out all new lines
predCode = regexprep(predCode, '\n+', ' ');
predCode = regexprep(predCode, '^\s*(.*?)\s*$', '$1');

str = sprintf('%s = logical(%s);', predVar, predCode);

map = create_autogen_map('condition', predIdx);
compose_eml_script('append', str, map);
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_eval_flag_word(table)

nP = length(table.predVar);
if ~(nP > 0 && table.useFlags)
    return;
end

str = '% Evaluate flagword from conditions. First condition is LSB.';
str = sprintf('%s\n%s = %s(%s);', str, table.flagVar, table.flagType, table.predVar{nP});

for i = nP-1:-1:1
    str = sprintf('%s\n%s = bitshift(%s, uint8(1));', str, table.flagVar, table.flagVar);
    str = sprintf('%s\n%s = bitor(%s, %s(%s));', str, table.flagVar, table.flagVar, table.flagType, table.predVar{i});
end

compose_eml_script('append', str);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_init_condition_vars(table)

nVars = length(table.predVar);

str = '';
for i = 1:nVars
    str = sprintf('%s%s = false;\n', str, table.predVar{i});
end

compose_eml_script('append', str);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dump_decision_code(decIdx, table, prefix)

m = size(table.predBody, 1);
condStr = '';
andStr = ' && ';
andLen = length(andStr);

for k = 1:m
    boolVal = table.predBody(k, decIdx);
    
    if table.useFlags
        var = sprintf('c%d', k);
    else
        var = table.predVar{k};
    end

    if boolVal > 0
        condStr = sprintf('%s%s%s', condStr, var, andStr);
    elseif boolVal == 0
        condStr = sprintf('%s~%s%s', condStr, var, andStr);
    else
        continue; % dont care
    end
end

if ~isempty(condStr)
    condStr = condStr(1:end-andLen);
end

str = '';
if table.useFlags
    if table.flagMask(decIdx) ~= 0
        % not default column, i.e. all don't cares
        str = sprintf('bitand(%s, %s(%d)) == %s(%d)', table.flagVar, table.flagType, table.flagMask(decIdx), table.flagType, table.flagValue(decIdx));
        str = sprintf('(%s)', str);
    end
else
    if ~isempty(condStr)
        str = sprintf('(%s)', condStr);
    end
end

if isempty(str)
    % all don't care column.
    str = '% Default';
end

str = [prefix ' ' str];

map = create_autogen_map('decision', decIdx);
compose_eml_script('append', str, map);
            
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autogenMap = create_autogen_map(type, index)

typeIdx = 0;

switch type
case 'condition'
    typeIdx = 0;
case 'action'
    typeIdx = 1;
case 'decision'
    typeIdx = 2;
otherwise
    error('Stateflow:UnexpectedError','Unknown type');
end

autogenMap.type= typeIdx;
autogenMap.index = index;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pStr = get_prototype(table)

chart = sf('get', table.id, 'state.chart');

if is_eml_truth_table_chart(chart)
    pStr = sf('ChartPrototype', chart);
else
    pStr = sf('get', table.id, 'state.labelString');
end

pStr = ['function ' pStr];

return;
