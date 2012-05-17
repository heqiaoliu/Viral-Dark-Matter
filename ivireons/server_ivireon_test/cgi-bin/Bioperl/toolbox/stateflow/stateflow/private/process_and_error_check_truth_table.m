function [errorCount, table] = process_and_error_check_truth_table(fcnId)

% Copyright 2004-2008 The MathWorks, Inc.

construct_tt_error('reset');

table = initialize_table(fcnId);
table = error_check_truth_table(table);
table = get_flagword_properties(table);

errorCount = construct_tt_error('get');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table = initialize_table(fcnId)

%----------- init table structure ----------
table.id = fcnId;
table.name = truth_table_man('get_name', fcnId);
table.fullname = truth_table_man('get_full_name', fcnId);

% Predicate table formating
table.idxPredDesp  = 1; % The index of column which holds predicate description in predicate table
table.idxPredLabel = 2; % The index of column which holds predicate label in predicate table
table.idxPredCode  = 3; % The index of column which holds predicate code in predicate table

% Action table formating
table.idxActDesp  = 1; % The index of column which holds action description in action table
table.idxActLabel = 2; % The index of column which holds action label in action table
table.idxActCode  = 3; % The index of column which holds action code in action table

% Diagnostics setting
table.diagError   = 0;
table.diagWarning = 1;
table.diagIgnore  = 2;

table.diagOverSpec  = sf('get',fcnId,'state.truthTable.diagnostic.overSpecification');
table.diagUnderSpec = sf('get',fcnId,'state.truthTable.diagnostic.underSpecification');

% Table pieces
table.predHeader = cell(0, 3);
table.predBody   = cell(0, 0);
table.predAction = cell(1, 0);
table.actions    = cell(0, 3);

% Initial and final action index
table.initActIdx  = 0;
table.finalActIdx = 0;

%----------- segment raw tables ----------
predicateTable =  sf('get',fcnId,'state.truthTable.predicateArray');
actionTable =  sf('get',fcnId,'state.truthTable.actionArray');

if isempty(actionTable)
    % G182707: Make empty action table empty 0x2 cell array
    actionTable = cell(0,2);
end

if isempty(predicateTable)
    % G141792: Initialize with the minimum predicate table.
    predicateTable = {'' ''};
end

% Trim heading/tailing white spaces
predicateTable = regexprep(predicateTable, '^\s*(.*?)\s*$', '$1');
actionTable = regexprep(actionTable, '^\s*(.*?)\s*$', '$1');

% Expand action table (desp, action) => (desp, label, action)
% Action can be referred by row number or label. label is optional.
[label code] = divide_label_code(actionTable(:, 2));
table.actions = [actionTable(:, 1) label code];

% Process predicate table
CIDX_TABLE_START = 3;
[m n] = size(predicateTable);
[label code] = divide_label_code(predicateTable(1:m-1,2));

table.predHeader = [predicateTable(1:m-1, 1) label code];
predAction = predicateTable(m, CIDX_TABLE_START:n);
predBody = predicateTable(1:(m-1), CIDX_TABLE_START:n);

%----------- normalize tables ----------
% create action string to index mapping
mapActionIndex = [];
for i = 1:size(table.actions, 1)
    mapActionIndex.(get_key(i)) = i;
    actLabel = table.actions{i, table.idxActLabel};

    if ~isempty(actLabel)
        key = get_key(actLabel);
        if isfield(mapActionIndex, key)
            ov = mapActionIndex.(key);
            errorMsg = sprintf('Action Table, actions %d and %d: Duplicate action label ''%s''.', ov, i, actLabel);
            local_error(table, errorMsg, 0, 'action', i);
        end

        mapActionIndex.(key) = i;

        if strcmpi(actLabel, 'init')
            table.initActIdx = i;
        end
        
        if strcmpi(actLabel, 'final')
            table.finalActIdx = i;
        end
    end
end

% convert predBody true/false/don't care string value to 1/0/-1
[m n] = size(predBody);
table.predBody = zeros(m, n);
for row = 1:m
    for col = 1:n
        switch lower(predBody{row, col})
            case {'t','y','1','true','yes'}
                table.predBody(row, col) = 1;
            case {'f','n','0','false','no'}
                table.predBody(row, col) = 0;
            case {'-','x'}
                table.predBody(row, col) = -1;
            case ''
                errorMsg = sprintf('Condition Table, column D%d, row %d: T/F/- cells cannot be empty.', col, row);
                local_error(table, errorMsg, 0);
            otherwise
                errorMsg = sprintf('Condition Table, column D%d, row %d: Invalid boolean string ''%s''.', col, row, predBody{row, col});
                local_error(table, errorMsg, 0);
        end
    end
end

% Whether table has default decision as last column
if ~isempty(table.predBody)
    table.hasDefault = (sum(table.predBody(:,n)) == -m);
end
    
% cache actions for each decision column
n = length(predAction);
table.predAction = cell(n, 1);
for i = 1:n
     actions = sf('SplitStringIntoCells', predAction{i}, ';,', 0);
     for j = 1:length(actions)
         key = get_key(actions{j});
         if isfield(mapActionIndex, key)
             idx = mapActionIndex.(key);
             table.predAction{i} = [table.predAction{i} idx];
         else
             errorMsg = sprintf('Condition Table, column D%d: Action ''%s'' is not defined in Action Table.', i, actions{j});
             local_error(table, errorMsg, 0, 'decision', i);
             % leave table.predAction{i} empty instead of aliasing.
         end
     end
end

% name pred vars
nP = size(predBody, 1);
table.predVar = cell(nP, 1);
for i = 1:nP
    varName = table.predHeader{i, table.idxPredLabel};
    if isempty(varName)
        varName = ['aVarTruthTableCondition_' int2str(i)];
    end
    table.predVar{i} = varName;
end

% name action functions
nA = size(table.actions, 1);
table.actionFcn = cell(nA, 1);
for i = 1:nA
    fcnName = table.actions{i, table.idxActLabel};
    if isempty(fcnName)
        fcnName = ['aFcnTruthTableAction_' int2str(i)];
    end
    table.actionFcn{i} = fcnName;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table = get_flagword_properties(table)

% Check for using flagword algorithm (generally faster)
table.useFlags = truth_table_gen_use_flags_algorithm(table.id);

if table.useFlags
    % name flagword var name
    nameLen = length(table.name);
    if nameLen > 20
        nameLen = 20;
    end
    table.flagVar = ['cflags_' regexprep(table.name(1:nameLen), '\W', '_')];
    
    % Calculate the flag mask and flag values for all decisitions
    [table.flagValue, table.flagMask] = get_flag_value_and_mask(table.predBody);
    
    % Flag word type
    table.flagType = 'uint32';
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [flagValue, flagMask] = get_flag_value_and_mask(predBody)

[nP, nD] = size(predBody);
flagMask  = zeros(nD, 1);
flagValue = zeros(nD, 1);

for d = 1:nD
    for c = 1:nP
        boolVal = predBody(c, d);
        bitsig  = pow2(c-1); % value of bit position in a uint
        if boolVal > 0
            flagValue(d) = flagValue(d) + bitsig;
            flagMask(d)  = flagMask(d)  + bitsig; % a 1-bit in the mask
        elseif boolVal == 0
            flagMask(d)  = flagMask(d)  + bitsig; % a 1-bit in the mask
        else
            continue; % a "don't care" entry
        end
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [label, code] = divide_label_code(ttStrCellArr)
% Divide truth table condition/action string to couples(label String, code String)
% Input string should have no heading/tailing white space.
% Label must begin with [a-zA-Z] followed by arbitray number of [a-zA-Z_0-9], end with a ':[^=]'

numStr = length(ttStrCellArr);
label = cell(numStr, 1);
code = cell(numStr, 1);

tokens = regexp(ttStrCellArr, '^\s*([a-zA-Z]\w*)\s*:(?!=)\s*(.*)', 'tokens', 'once');

for i = 1:numStr
    if ~isempty(tokens{i})
        label{i} = tokens{i}{1};
        code{i} = tokens{i}{2};
    else
        label{i} = '';
        code{i} = ttStrCellArr{i};
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function table = error_check_truth_table(table)

% ------------------- check action table -----------------------
[m n] = size(table.actions);

% "check for vacant action code"
% for r = 1:m
%     if isempty(table.actions{r, table.idxActCode})
%         warnMsg = ['Action Table, action ' int2str(r) ': Empty action string.'];
%         local_warn(table, warnMsg, 'action', r);
%     end
% end

% "Detect duplicate action labels" is done in "initialize_table"

% "Detect unreferred actions (by condition table)"
unreferredAct = setdiff([1:m], [table.predAction{:} table.initActIdx table.finalActIdx]);
if ~isempty(unreferredAct)
    warnMsg = sprintf('Action Table, actions (%s): Unreferred actions by Condition Table.', int2str(unreferredAct));
    local_warn(table, warnMsg, 'action', unreferredAct(1));
end

% ------------------- check condition table ----------------------
[m n] = size(table.predBody);

% "check for duplicate predicate label, or other data collisions"
hashUserPredLabel = [];
hashAutoPredLabel = [];
ttUserCreatedData = sf('find',sf('DataOf',table.id),'data.autogen.isAutoCreated',0);
for i = 1:m
    if isempty(table.predHeader{i, table.idxPredLabel})
        autoPredLabel = table.predVar{i};
        hashAutoPredLabel.(get_key(autoPredLabel)) = i;
        existingData = sf('find',ttUserCreatedData,'data.name',autoPredLabel);
        if ~isempty(existingData)
            % Auto created condition label collides with user defined data
            errorMsg = sprintf('Condition Table, autocreated label ''%s'' for condition %d collides with a user created data #%d',...
                               autoPredLabel,i,existingData(1));
            local_error(table, errorMsg, 0, 'condition', i);
        end
    end
end
for i = 1:m
    predLabel = table.predHeader{i, table.idxPredLabel};
    if ~isempty(predLabel)
        key = get_key(predLabel);
        if isfield(hashUserPredLabel, key)
            % Duplicate user defined condition labels
            ov = hashUserPredLabel.(key);            
            errorMsg = sprintf('Condition Table, conditions %d and %d: Duplicate condition label ''%s''.', ov, i, predLabel);
            local_error(table, errorMsg, 0, 'condition', i);
        end
        hashUserPredLabel.(key) = i;

        if isfield(hashAutoPredLabel, key)
            av = hashAutoPredLabel.(key);
            % Collision of user defined condition label with autocreated condition label
            errorMsg = sprintf('Condition Table, user label ''%s'' in condition %d collides with an autocreated label for condition %d',...
                               predLabel,i,av);
            local_error(table, errorMsg, 0, 'condition', i);
        end
        
        existingData = sf('find',ttUserCreatedData,'data.name',predLabel);
        if ~isempty(existingData)
            % User condition label collides with user defined data
            errorMsg = sprintf('Condition Table, user label ''%s'' in condition %d collides with a user created data #%d',...
                               predLabel,i,existingData(1));
            local_error(table, errorMsg, 0, 'condition', i);
        end
    end
end

% "check for vacant predicate/condition code"
for r = 1:m
    if isempty(table.predHeader{r, table.idxPredCode})
        errorMsg = sprintf('Condition Table, condition %d: Empty condition string.', r);
        local_error(table, errorMsg, 0, 'condition', r);
    end
end

% "check for true/false string value" is done in "initialize_table"

% "all dont care column, if exists, should always be the last column"
if m > 0 && n > 1
    if(m>1)
        % multiple predicates
        tmp = sum(table.predBody);
    else
        % single predicate
        tmp = table.predBody;
    end
    nonEndingDontCareCols = find(tmp(1:n-1) == -m);
    if ~isempty(nonEndingDontCareCols)
        errorMsg = sprintf('Condition Table, columns D(%s): Default decision column (containing all ''don''t cares'') must be the last column.', int2str(nonEndingDontCareCols));
        local_error(table, errorMsg, 0, 'decision', nonEndingDontCareCols(1));
    end
end

% "Check for undefined action in predicate table, action row" is done in initialize_table

% "Check for vacant action for a decision column in conditon table"
for i = 1:n
    if isempty(table.predAction{i})
        errorMsg = sprintf('Condition Table, column D%d: No action is specified.', i);
        local_error(table, errorMsg, 0, 'decision', i);
    end
end

% "Check for the use of reserved INIT FINAL actions in condition table"
useInitCols = []; useFinalCols = [];
for i = 1:n
    if ~isempty(find(table.predAction{i} == table.initActIdx, 1))
        useInitCols = [useInitCols i];
    end
    if ~isempty(find(table.predAction{i} == table.finalActIdx, 1))
        useFinalCols = [useFinalCols i];
    end
end
if ~isempty(useInitCols)
    warnMsg = sprintf('Condition Table, columns D(%s): Action ''INIT'' is reserved for truth table initialization. It should not be explicitly referred.', int2str(useInitCols));
    local_warn(table, warnMsg, 'decision', useInitCols(1));
end
if ~isempty(useFinalCols)
    warnMsg = sprintf('Condition Table, columns D(%s): Action ''FINAL'' is reserved for truth table finalization. It should not be explicitly referred.', int2str(useFinalCols));
    local_warn(table, warnMsg, 'decision', useFinalCols(1));
end

% Warn about empty condition table body
if isempty(table.predBody)
    warnMsg = 'Condition Table: Truth table body is empty without decision columns.';
    local_warn(table, warnMsg);
    
    if m > 0
        warnMsg = 'Condition Table: Empty truth table is underspecified.';
        switch table.diagUnderSpec
            case table.diagError
                local_error(table, warnMsg, 0);
            case table.diagWarning
                local_warn(table, warnMsg);
            otherwise
        end
    end
end

% Early return if there have been earlier errors, OR if table body is empty
if construct_tt_error('get') > 0 || isempty(table.predBody)
    return;
end

% "Check for truth table under, over specification"
definitelyFullySpecified = false; % Whether table is fully specified per our knowledge

if(table.diagOverSpec~=table.diagIgnore || table.diagUnderSpec~=table.diagIgnore)
    % do the computation only if atleast one of the settings 
    % is set to error or warn
    magicNumber = 20;
    if(m<=magicNumber)
        mySpecCheck = exist('my_tt_check_specification.m','file');
        if mySpecCheck == 2 || mySpecCheck == 3
            % User specified diagnostice function
            [over under] = my_tt_check_specification(table.predBody);
        else
            % Default diagnostic function
            [over under] = tt_check_specification(table.predBody);
        end
        
        if isempty(under)
            definitelyFullySpecified = true;
        end
    else
        msg = sprintf('Truth table contains more than %d conditions. Skipping (over/under)specification checks as it may take a long time',magicNumber);
        local_warn(table, msg);
        over = [];
        under = [];
    end
end
if(table.diagOverSpec==table.diagIgnore)
    % prevent
    over = [];
end
if(table.diagUnderSpec==table.diagIgnore)
    under = [];
end

numCaseReport = 23; % number of over or under cases to report

if ~isempty(over)
    warnMsg = sprintf('Overspecification found in Condition Table:\n');
    for i = 1:min(length(over), numCaseReport)
        warnMsg = sprintf('%sColumn D%d is overspecified by columns D(%s)\n', warnMsg, over{i}(1), int2str(over{i}(2:end)));
    end
    if length(over) > numCaseReport
        warnMsg = sprintf('%s... (%d more)', warnMsg, length(over) - numCaseReport);
    end
    
    if (table.diagOverSpec == table.diagError)
        local_error(table, warnMsg, 0, 'decision', over{1}(1));
    else
        local_warn(table, warnMsg, 'decision', over{1}(1));
    end
end

if ~isempty(under)
    underCount = length(under);

    % Considering the long time for quine_mcclusky on large set
    complexityBound = 1024;
    
    underStr = quine_mcclusky(dec2bin(under(1:min(underCount, complexityBound)), m), 0);
    
    tailing = [];
    if underCount > complexityBound || size(underStr, 1) > numCaseReport
        midPos = ceil(m / 2);
        tailStr = sprintf(' ... more');
        tailing = [char(32*ones(midPos-1, length(tailStr))); tailStr; char(32*ones(m-midPos, length(tailStr)))];
    end
    
    underStr = underStr(1:min(size(underStr, 1), numCaseReport), :);
    underStr(find(underStr == '1')) = 'T';
    underStr(find(underStr == '0')) = 'F';
    underStr = char(regexprep(cellstr(rot90(underStr)), '([\w-])', '$1   '));
    underStr = [underStr tailing];

    warnMsg = sprintf('Underspecification found in Condition Table for following missing cases:\n');
    for i = 1:size(underStr, 1)
        warnMsg = sprintf('%s%s\n', warnMsg, underStr(i, :));
    end

    if (table.diagUnderSpec == table.diagError)
        local_error(table, warnMsg, 0);
    else
        local_warn(table, warnMsg);
    end
end

% eM truth table has to contain default decision.
if is_eml_truth_table_fcn(table.id) && ~table.hasDefault
    if definitelyFullySpecified
        % Convert last column to be default decision
        table.predBody(:, n) = -1;
        table.hasDefault = true;
    else
        % Force user to add default decision
        errMsg = ['Truth Table using Embedded MATLAB language has to be fully specified.' 10 ...
                  'This table is either underspecified, or its specification can''t be determined.' 10 ...
                  'To make this table fully specified, consider adding a default (all don''t cares) decision.'];
        local_error(table, errMsg, 0);
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errStr, openFcn] = local_construct_error(table, msg, type, index)

if nargin >= 4
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
    link = sprintf('(#%d.%d.%d), %s %d', table.id, typeIdx, index, type, index);
    openFcn = sprintf('sf(''Open'', %d, %d, %d);', table.id, typeIdx, index);
else
    link = sprintf('(#%d)', table.id);
    openFcn = sprintf('sf(''Open'', %d);', table.id);
end

errStr = sprintf('Truth Table ''%s'' %s:\n\n%s', table.name, link, xlate(msg));

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_error(table, errorMsg, throwFlag, type, index)

if nargin >= 5
    [errorMsg, openFcn] = local_construct_error(table, errorMsg, type, index);
else
    [errorMsg, openFcn] = local_construct_error(table, errorMsg);
end

construct_tt_error('add', table.id, errorMsg, throwFlag, openFcn);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_warn(table, warnMsg, type, index)

if nargin >= 4
    [warnMsg, openFcn] = local_construct_error(table, warnMsg, type, index);
else
    [warnMsg, openFcn] = local_construct_error(table, warnMsg);
end

construct_warning(table.id, 'Parse', warnMsg, openFcn);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key = get_key(label)
% "label" must be a scalar integer value OR a string

prefix = 'K';
if isnumeric(label)
    label = int2str(label);
end
key = [prefix label];
