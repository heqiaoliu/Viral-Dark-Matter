function result = truth_table_function_man(methodName, objectId, varargin)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2009/11/19 16:54:28 $

result = [];

% Input object should be Stateflow truthtable function
if ~sf('ishandle',objectId) || ~is_truth_table_fcn(objectId)
    return;
end

try
    switch(methodName)
        case {'create_ui', 'destroy_ui', 'destroy_ui_side_effect', ...
              'view_content', 'get_name', 'get_full_name'}
            result = feval(methodName, objectId);
        case {'set_title', 'highlight', 'dehighlight'}
            result = feval(methodName, objectId, varargin{:});
        case {'update_data', 'update_layout_data', 'update_ui', 'compile', ...
              'lock_editor', 'add_data', 'update_active_instance', 'rtw_highlight_code', 'hdl_highlight_code'}
            set_title(objectId);
            result = feval(methodName, objectId, varargin{:});
        case {'generate_html', 'print', 'open_in_browser', 'mark_clean', ...
              'goto_sf_editor', 'goto_sf_explorer', 'save_model', ...
              'save_model_as', 'export_as_html'}
            set_title(objectId);
            result = feval(methodName, objectId);
        otherwise,
            fprintf(1,'Unknown methodName %s passed to truth_table_function_man', methodName);
    end
catch ME
    str = sprintf('Error calling truth_table_function_man(%s): %s', methodName, ME.message);
    if ~strcmp(methodName, 'create_ui')
        construct_error(objectId, 'Truth Table', str, 0);
        slsfnagctlr('ViewNaglog');
    else
        str = sprintf('Error opening the truth table editor:\n%s\n', ME.message);
        disp(str);
        errordlg(str, 'Truth table editor creation failed', 'replace');
    end
end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = save_model(objectId)
result = [];

chart = sf('get', objectId, '.chart');
machine = sf('get', chart, '.machine');
% sfsave will do all eML, truthtable data updation from editor
sfsave(machine, [], 1);

return;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = save_model_as(objectId)
result = [];

chart = sf('get', objectId, '.chart');
machine = sf('get', chart, '.machine');
% sfsave will do all eML, truthtable data updation from editor
sfsave(machine, sf('get',machine,'.name'), 1);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = export_as_html(objectId)
result = [];

[fullName, ttName] = truth_table_name(objectId);
htmlName = [ttName, '.html'];
[f, p] = uiputfile(htmlName, ttName);
if f ~= 0
    pwdDir = pwd;
    cd(p);
    try
        fFullName = fullfile(pwd, f);
        fp = fopen(fFullName, 'w');
        str = generate_html(objectId);
        fprintf(fp, '%s', str);
        fclose(fp);
        web(fFullName);
    catch ME
        errordlg(ME.message);
    end
    cd(pwdDir);
end

return;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = lock_editor(objectId, mode)
    % mode: lock/unlock = true/false
    result = [];

    tableH = sf('get', objectId, 'state.truthTable.hPredicateArray');
    if(~isempty(tableH) && ishandle(tableH))
        tableH.lock(mode);
    end
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = add_data(objectId, scope, showDialog)
    result = [];
    
    if nargin < 3
        showDialog = false;
    end
    
    switch lower(scope)
        case 'input'
            scope = 'Function input';
        case 'output'
            scope = 'Function output';
    end
    
    hObj = idToHandle(sfroot, objectId);
    d = Stateflow.Data(hObj);
    d.Scope = scope;
    
    if showDialog
        sfdlg(d.id, 1);
    end
    
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_editor(objectId)
    result = [];
    
    chartId = sf('get', objectId, '.chart');
    if chartId > 0
        sf('Open', chartId);
        sf('FitToView', chartId, objectId);
    end
    
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_explorer(objectId)

    result = [];
    sf('Explr');
    sf('Explr', 'VIEW', objectId);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = view_content(objectId)
    result = [];

    sf('ViewContent', objectId);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = highlight(objectId, itemType, itemIdx)
    result = [];

    tableH = sf('get', objectId, 'state.truthTable.hPredicateArray');

    if ~isempty(tableH) && ishandle(tableH)
        switch itemType
        case {0, 'condition'}
            tableH.setHighlight('p', 'r', itemIdx);
        case {1, 'action'}
            tableH.setHighlight('a', 'r', itemIdx);
        case {2, 'decision'}
            tableH.setHighlight('p', 'c', itemIdx);
        end
    end

    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = dehighlight(objectId)
    result = [];
    tableH = sf('get', objectId, 'state.truthTable.hPredicateArray');
    if ~isempty(tableH) && ishandle(tableH)
        tableH.clearHighlight;
    end

	return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(objectId)
    
    result = [];
    if ~jvmAvailable
        error('Stateflow:UnexpectedError','%s','Truth table editor requires Java Swing and AWT components. One of these components in missing.');
    end

    propName = 'state.truthTable.hPredicateArray';
    tableH = sf('get', objectId, propName);

    if(isempty(tableH) || ~ishandle(tableH))
        predicateTable = sf('get', objectId, 'state.truthTable.predicateArray');
        actionTable = sf('get', objectId, 'state.truthTable.actionArray');

        if isempty(predicateTable) || (size(predicateTable, 1) == 1 && length(predicateTable) <= 2)
            predicateTable = truth_table_man('construct_initial_predicate_table');
            sf('set', objectId, 'state.truthTable.predicateArray', predicateTable);
        end
        
        if isempty(actionTable)
            actionTable = truth_table_man('construct_initial_action_table');
            sf('set', objectId, 'state.truthTable.actionArray', actionTable);
        end
        
        % Construct the truth table editor UI
        if use_handle_cache
            tableH = truth_table_handle_man('open', objectId, predicateTable, actionTable);
        else
            %import com.mathworks.toolbox.stateflow.truthtable.*;
            %tableH = TruthTableEditor(objectId, predicateTable, actionTable);
        end
             
        % The editor title
        tableH.setTitleFromSf(create_title_string(objectId));

        % Recovering the editor layout at last save
        layout = sf('get', objectId, 'state.truthTable.editorLayout');
        if isempty(layout)
            tableH.setDividerLocationRelative(0.5);
        else
            if isfield(layout, 'dim')
                tableH.setTruthTableSize(layout.dim);
            end
            if isfield(layout, 'div')
                tableH.setDividerLocation(layout.div);
            end
            if isfield(layout, 'pcw')
                tableH.setPredicateTableColumnWidths(layout.pcw);
            end
            if isfield(layout, 'acw')
                tableH.setActionTableColumnWidths(layout.acw);
            end
            if isfield(layout, 'prh')
                tableH.setPredicateTableRowHeights(layout.prh);
            end
            if isfield(layout, 'arh')
                tableH.setActionTableRowHeights(layout.arh);
            end
        end

        % Set over/under specification diagnostic mode
        underSpecDiagnostic = sf('get',objectId,'state.truthTable.diagnostic.underSpecification');
        overSpecDiagnostic = sf('get',objectId,'state.truthTable.diagnostic.overSpecification');
        tableH.setUnderSpecDiagMode(underSpecDiagnostic, 0);
        tableH.setOverSpecDiagMode(overSpecDiagnostic, 0);

        % Set language mode
        tableH.setLanguage(sf('get',objectId,'state.truthTable.useEML'), 0);
        
        % Set "is truth table block?"
        chartId = sf('get', objectId, '.chart');
        isTTBlock = is_truth_table_chart(chartId);
        tableH.setIsTruthTableBlock(isTTBlock);
        
        % Cache the editor UI handle
        sf('set',objectId,propName,tableH);
    else
        if use_handle_cache
            truth_table_handle_man('touch', objectId);
        end
    end

    tableH.showEditor;
    chart = sf('get',objectId,'state.chart');
    if(sf('get',chart,'chart.iced'))
        tableH.lock(1);
    end
    result = tableH;
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = destroy_ui_side_effect(objectId)
    result = [];

    tableH = sf('get',objectId,'state.truthTable.hPredicateArray');

    if(~isempty(tableH) && ishandle(tableH))
        update_data(objectId); % redundant, make sure data is update
        update_layout_data(objectId);
        
        if use_handle_cache
            tableH.recycleEditor; % Make table invisible and clean up the mess inside
        else
            tableH.closeEditor;
        end
    end

	sf('set',objectId,'state.truthTable.hPredicateArray',[]);
    tableH = [];
    clear tableH;

    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = destroy_ui(objectId)
    result = [];

    destroy_ui_side_effect(objectId);
    
    % Close the data event manager if there is one open
    chart = sf('get', objectId, '.chart');
    if is_truth_table_chart(chart)
        sf_de_manager('close', chart);
    end
    
    if use_handle_cache
        truth_table_handle_man('close', objectId);
    end
        
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellArray = java_to_cell(javaArray)

    m = length(javaArray);
    if(m>0)
        n = length(javaArray(1));
    else
        n = 0;
        cellArray = {};
        return;
    end


    cellArray = cell(m, n);
    for i = 1:m
        jCol = javaArray(i);
        for j = 1:n
            cellArray{i, j} = char(jCol(j));
        end
    end

    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_title(objectId)
    result = [];
    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if(isempty(tableH) || ~ishandle(tableH))
        return;
    end
    
    titleStr = create_title_string(objectId);
    tableH.setTitleFromSf(titleStr);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function titleStr = create_title_string(objectId)

    chartId = sf('get', objectId, '.chart');
    chartName = chart2name(chartId);
    
    if is_truth_table_chart(chartId)
        titleStr = ['Block: ' chartName];
    else
        titleStr = ['Stateflow (truth table) ', chartName, '.', sf('FullNameOf', objectId, chartId, '.')];
    end
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function name = get_name(objectId)

[fullname, name] = truth_table_name(objectId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fullname = get_full_name(objectId)

fullname = truth_table_name(objectId);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fullname, shortname] = truth_table_name(objectId)

    chartId = sf('get', objectId, '.chart');
    [fullname, shortname] = chart2name(chartId);
    
    if ~is_truth_table_chart(chartId)
        shortname = sf('get', objectId, '.name');
        fullname = [fullname '/' sf('FullNameOf', objectId, chartId, '/')];
    end
    
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_ui(objectId, varargin)
    % update_ui is a one direction call, from SF -> UI
    % UI side should not call back Stateflow to update data
    result = [];
    if nargin < 3
        return;
    end

    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if(isempty(tableH) || ~ishandle(tableH))
        return;
    end
    
    % Make sure that the table editing is finished
    editor_stop_editing(objectId);

    switch varargin{1}
        case 'predicate_cell'
            tableH.setPredicateTableCellValue(varargin{2}, varargin{3}, varargin{4}, 0);
        case 'action_cell'
            tableH.setActionTableCellValue(varargin{2}, varargin{3}, varargin{4}, 0);
        case 'predicate_array'
            tableH.updatePredicateTableEditor(varargin{2});
        case 'action_array'
            tableH.updateActionTableEditor(varargin{2});
        case 'overspec_diag'
            tableH.setOverSpecDiagMode(varargin{2}, 0);
        case 'underspec_diag'
            tableH.setUnderSpecDiagMode(varargin{2}, 0);
        case 'language'
            tableH.setLanguage(varargin{2}, 0);
        otherwise
            return;
    end

    tableH.setDirty(1);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(objectId)
% Implement this function when debugging is available from UI

result = [];
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editor_stop_editing(objectId)
% Request Truthtable UI to stop editing, and promptly update the editing
% content to Stateflow DD.

tableH = sf('get',objectId,'state.truth.hPredicateArray');
if (~isempty(tableH) && ishandle(tableH))
    editingStatus = tableH.stopEditingCell;
    if ~isempty(editingStatus)
        try
            sf('UpdateTruthTableCell', objectId, str2num(editingStatus(1)), str2num(editingStatus(2)), str2num(editingStatus(3)), char(editingStatus(4)));
        catch ME
            disp(ME.message);
            update_data(objectId);
        end
        tableH.setDirty(1);
    end
end
return;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(objectId,varargin)

    result = [];
    isDirty = 0;
    updateAllData = 0;

    if nargin > 1
        % All data update mode here are one way (from UI->SF, except for 'snr').
        % And data is truly changed. No need to compare with old values.
        switch varargin{1}
            case 'cell'
                try
                    sf('UpdateTruthTableCell',objectId,varargin{2},varargin{3},varargin{4},varargin{5});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'swap'
                try
                    sf('SwapTruthTableRowColumn',objectId,varargin{2},varargin{3},varargin{4},varargin{5});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'move'
                try
                    sf('MoveTruthTableRowColumn',objectId,varargin{2},varargin{3},varargin{4},varargin{5});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'add'
                try
                    sf('AddTruthTableRowColumn',objectId,varargin{2},varargin{3},varargin{4},varargin{5});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'delete'
                try
                    sf('DeleteTruthTableRowColumn',objectId,varargin{2},varargin{3},varargin{4});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'array'
                try
                    sf('UpdateTruthTableArray',objectId,varargin{2},varargin{3});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'diagnostic'
                sf('TurnOffTruthTableUIUpdates',1);
                switch varargin{2}
                    case 'overspec'
                        sf('set',objectId,'state.truthTable.diagnostic.overSpecification',varargin{3});
                    case 'underspec'
                        sf('set',objectId,'state.truthTable.diagnostic.underSpecification',varargin{3});
                    otherwise
                        error('Stateflow:UnexpectedError','Unknown diagnostics mode in data update.');
                end
                sf('TurnOffTruthTableUIUpdates',0);
            case 'language'
                sf('TurnOffTruthTableUIUpdates',1);
                sf('set',objectId,'state.truthTable.useEML',varargin{2});
                sf('TurnOffTruthTableUIUpdates',0);
            case 'snr'
                % This method should only be called by search and replace
                % ('update_data', ttId, 'snr', {pred=0,act=1}, row, column, newString)
                if varargin{2} == 0
                    update_ui(objectId, 'predicate_cell', varargin{5}, varargin{3}, varargin{4});
                else
                    update_ui(objectId, 'action_cell', varargin{5}, varargin{3}, varargin{4});
                end
                try
                    sf('UpdateTruthTableCell',objectId,varargin{2},varargin{3}-1,varargin{4}-1,varargin{5});
                catch ME
                    disp(ME.message);
                    update_data(objectId);
                end
            case 'stop_editing'
                % This methold is call by ted_the_editors to make sure the
                % truthtable editing cell are get updated to SF promptly
                editor_stop_editing(objectId);
            otherwise
                error('Stateflow:UnexpectedError','Unknown data update mode');
        end

        isDirty = 1;
    else
        updateAllData = 1;
    end

    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if(isempty(tableH) || ~ishandle(tableH))
        return;
    end

    if (updateAllData)
        % Make sure that the table editing is finished
        editor_stop_editing(objectId);

        jPredicateTable = tableH.getPredicateTableStringArray;
        jActionTable = tableH.getActionTableStringArray;

        % Update the properties only if they have changed
        % an accidental apply from the UI should not make the
        % diagram dirty
        newPredicateArray = java_to_cell(jPredicateTable);
        oldPredicateArray = sf('get', objectId, 'state.truthTable.predicateArray');
        if(~tt_isequal(newPredicateArray,oldPredicateArray))
            sf('TurnOffTruthTableUIUpdates',1);
            sf('set', objectId, 'state.truthTable.predicateArray', newPredicateArray);
            sf('TurnOffTruthTableUIUpdates',0);
            isDirty = 1;
        end

        newActionArray = java_to_cell(jActionTable);
        oldActionArray = sf('get', objectId, 'state.truthTable.actionArray');
        if(~tt_isequal(newActionArray,oldActionArray))
            sf('TurnOffTruthTableUIUpdates',1);
            sf('set', objectId, 'state.truthTable.actionArray', newActionArray);
            sf('TurnOffTruthTableUIUpdates',0);
            isDirty = 1;
        end

        oldUnderSpecDiagnostic = sf('get',objectId,'state.truthTable.diagnostic.underSpecification');
        oldOverSpecDiagnostic = sf('get',objectId,'state.truthTable.diagnostic.overSpecification');
        newUnderSpecDiagnostic = tableH.getUnderSpecDiagMode;
        newOverSpecDiagnostic = tableH.getOverSpecDiagMode;

        if(oldUnderSpecDiagnostic~=newUnderSpecDiagnostic)
            sf('TurnOffTruthTableUIUpdates',1);
            sf('set',objectId,'state.truthTable.diagnostic.underSpecification',newUnderSpecDiagnostic);
            sf('TurnOffTruthTableUIUpdates',0);
            isDirty = 1;
        end

        if(oldOverSpecDiagnostic~=newOverSpecDiagnostic)
            sf('TurnOffTruthTableUIUpdates',1);
            sf('set',objectId,'state.truthTable.diagnostic.overSpecification',newOverSpecDiagnostic);
            sf('TurnOffTruthTableUIUpdates',0);
            isDirty = 1;
        end
        
        oldLanguageSetting = sf('get',objectId,'state.truthTable.useEML');
        newLanguageSetting = tableH.getLanguage();
        if oldLanguageSetting ~= newLanguageSetting
            sf('TurnOffTruthTableUIUpdates',1);
            sf('set',objectId,'state.truthTable.useEML',newLanguageSetting);
            sf('TurnOffTruthTableUIUpdates',0);
            isDirty = 1;
        end
    end

    if(isDirty)
        tableH.setDirty(1);
    end

    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_layout_data(objectId)

    result = [];

    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if(isempty(tableH) || ~ishandle(tableH))
        return;
    end
    layout = [];
    layout.dim = double(tableH.getTruthTableSize);
    layout.div = double(tableH.getDividerLocation);
    layout.pcw = double(tableH.getPredicateTableColumnWidths);
    layout.acw = double(tableH.getActionTableColumnWidths);
    layout.prh = double(tableH.getPredicateTableRowHeights);
    layout.arh = double(tableH.getActionTableRowHeights);

    sf('set', objectId, 'state.truthTable.editorLayout', layout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = mark_clean(objectId,varargin)
    result = [];

    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if(isempty(tableH) || ~ishandle(tableH))
        return;
    end
    % Set the dirty flag to zero
    tableH.setDirty(0);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_busy_cursor(objectId, onOff)
    result = [];

    tableH = sf('get',objectId,'state.truth.hPredicateArray');
    if (isempty(tableH) || ~ishandle(tableH))
        return;
    end

    tableH.setBusyCursor(onOff);
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = generate_html(objectId)
    update_data(objectId); % redundant, make sure data is update
    result = sf('Private', 'state2html', objectId);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = print(objectId)
    [fullname, ttName] = truth_table_name(objectId);
    jobName = ['(truth table) ' ttName];
    result = print_html_str(generate_html(objectId), jobName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_in_browser(objectId)
    persistent browser;
    if isempty(browser)
        browser = com.mathworks.ide.html.HTMLBrowser.createBrowser;
    end
    browser.setHtmlText(generate_html(objectId));
    result = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = compile(objectId, checkErrorOnly)
    result = [];

    update_data(objectId); % redundant, make sure data is update

    if (nargin < 2)
        checkErrorOnly = 0;
    end

    chartId = sf('get',objectId,'state.chart');
    machineId = sf('get',chartId,'chart.machine');
    modelName = sf('get',machineId,'machine.name');
    slsfnagctlr('Clear', modelName, 'Stateflow Builder');

    set_busy_cursor(objectId, true);
    errorCount = 0;
    try
        if (checkErrorOnly)
            errorCount = process_and_error_check_truth_table(objectId);
        else
            errorCount = update_truth_table_for_fcn(objectId,0); % non-incremental compile
        end
    catch ME
        errorMsg = ME.message;
        construct_error(objectId, 'Truth Table', errorMsg,0);
        slsfnagctlr('ViewNaglog');
        set_busy_cursor(objectId, false);
        return;
    end
    set_busy_cursor(objectId, false);

    if (errorCount > 0)
        if (checkErrorOnly)
            errMsg = sprintf('%d error(s) found in truth table %s (#%d).', errorCount, truth_table_name(objectId), objectId);
        else
            errMsg = sprintf('Truth table generation failed for %s (#%d).', truth_table_name(objectId), objectId);
        end
        construct_error(objectId, 'Truth Table', errMsg, 0);
    else
    	% report success
    	% WISH this should be a function construct_nag_msg
    	sf('Open',objectId);
    	nag             = slsfnagctlr('NagTemplate');
   		nag.type        = 'Log';
    	if (checkErrorOnly)
        	nag.msg.details =  sprintf('No errors found in truth table %s (#%d).', truth_table_name(objectId), objectId);
    	else
        	nag.msg.details =  sprintf('Truth table generation was successful for %s (#%d).', truth_table_name(objectId), objectId);
    	end
    	nag.msg.type    = 'Build';
    	nag.msg.summary = nag.msg.details;
    	nag.component   = 'Stateflow';
    	nag.sourceHId   = objectId;
    	nag.ids         = objectId;
    	nag.blkHandles  = [];

    	slsfnagctlr('Naglog', 'push', nag);
    end

    slsfnagctlr('ViewNaglog');
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tof = jvmAvailable

    tof = usejava('jvm') & usejava('awt') & usejava('swing');
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function treats the arrays as equal
% if they are both empty. That is, [] is equal to {}
%
function isEqual = tt_isequal(array1,array2)
isEqual = 0;
if(isempty(array1) && isempty(array2))
    isEqual = 1;
else
    isEqual = isequal(array1,array2);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tof = use_handle_cache

tof = true;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = rtw_highlight_code(objectId, varargin)

result = [];

typeIndex = varargin{1};
index = varargin{2};

ssid = getObjectSSId(objectId, typeIndex, index);
if ~isempty(ssid)
   traceabilityManager('rtwTraceObject', ssid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = hdl_highlight_code(objectId, varargin)

result = [];

typeIndex = varargin{1};
index = varargin{2};

ssid = getObjectSSId(objectId, typeIndex, index);
if ~isempty(ssid)
   traceabilityManager('hdlTraceObject', ssid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objectSSId = getObjectSSId(objectId, typeIndex, index)

% for safety, try to update the truth-table info always
% I wodner if this will make it too slow for large charts ???
chartId = getChartOf(objectId);
update_truth_tables(chartId);

objectSSId = [];

if typeIndex < 0 || index < 0
    return;
end

root = sfroot;

% see if it is an eml truth table function
if(is_eml_truth_table_fcn(objectId))
    
    handle = root.idToHandle(objectId);
    objectSSId = handleTossId(handle);
    [blockPath, objectSSIdNumber, auxInfo] = traceabilityManager('parseSSId', objectSSId);
    if(isempty(blockPath))
        return;
    end
    
    mapping = sf('get', objectId, 'state.autogen.mapping');
    
    % search for the line with matching type and index
    for i = length(mapping) : -1 : 1
        
        emlLine = mapping(i, 1);
        emlLineMapping = mapping(i, 2);
        
        if ~isempty(emlLineMapping) && ~isempty(emlLineMapping{1}) && ...
                ~isempty(emlLine) && emlLineMapping{1}.type == typeIndex && ...
                emlLineMapping{1}.index == index
                        
            if ~isempty(objectSSId)
                objectSSId = traceabilityManager('makeSSId', blockPath, objectSSIdNumber, num2str(emlLine{1}));
            end
            
            return;
        end
    end
    
    return;
end

% get a list of all transition objects belonging to the truth table
TRANSITION_ISA = sf('get', 'default', 'transition.isa' );
objs = sf('find', 'all', '.isa', TRANSITION_ISA, ...
    'transition.autogen.source', objectId);

% search for the transition with matching type and index
for i = 1 : length(objs)
    
    mapping = sf('get', objs(i), 'transition.autogen.mapping');
    
    if ~isempty(mapping) && mapping.type == typeIndex && mapping.index == index
        
        handle = root.idToHandle(objs(i));
        objectSSId = handleTossId(handle);
        
        return;
    end
end

return;
