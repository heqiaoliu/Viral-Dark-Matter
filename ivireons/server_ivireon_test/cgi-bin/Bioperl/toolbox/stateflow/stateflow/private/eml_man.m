function [result, varargout] = eml_man(methodName, varargin)
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.48 $  $Date: 2010/02/25 08:39:51 $

result = [];

try
    switch (methodName)
        case {'help_stateflow',...
                'help_eml',...
                'help_desk',...
                'help_editor',...
                'help_library_ref',...
                'about_stateflow',...
                'get_editor',...
                'jvm_available',...
                'close_all_scripts'}
            result = feval(methodName);
        case {'manage_emldesktop',...
                'force_close_ui',...
                'update_debuggable_status',...
                'sfhelp_topic',...
                'eml_functions_help',...
                'eml_simevents_help',...
                'ml_function_exists',...
                'lock_editor',...
                'highlight',...
                'mark_clean',...
                'debugger_step',...
                'debugger_stop',...
                'debugger_continue',...
                'debugger_step_in',...
                'debugger_step_out',...
                'debugger_break',...
                'debugger_sfun_enable',...
                'debugger_chart_enable',...
                'check_symbol',...
                'browse_symbol',...
                'request_data_scope_change',...
                'set_data_scope',...
                'update_diagram',...
                'infer_dbg',...
                'refresh_breakpoints_display',...
                'get_sim_status',...
                'update_ui_state',...
                'register_breakpoint',...
                'clear_all_infer_and_runtime_breakpoints',...
                'clear_all_breakpoints',...
                'sim_command',...
                'notify_options',...
                'goto_sf_explorer',...
                'open_model',...
                'open_mfile',...
                'simulation_target',...
                'rtw_target',...
                'rtw_highlight_code',...
                'hdl_highlight_code',...
                'open_editor'
                }
            result = feval(methodName, varargin{:});
        case {'get_editor_for_opened_object'}
            if nargout > 1
                [result varargout{1}] = feval(methodName, varargin{:});
            else
                result = feval(methodName, varargin{:});
            end
        case 'find_prototype_str'
            [result, varargout{1}, varargout{2}] = feval(methodName, varargin{:});
        case 'create_ui'
            result = dispatch_task(methodName, varargin{:});
        case {'edit_data_ports', ...
                'goto_sf_editor'}
            varargin{1} = eml_fcn_source(varargin{1});
            result = dispatch_task(methodName, varargin{:});
        otherwise
            result = dispatch_task(methodName, varargin{:});
    end
catch ME
    str = sprintf('Error calling eml_man(%s): %s',methodName,ME.message);
    construct_error([], 'Embedded MATLAB', str, 0);
    slsfnagctlr('ViewNaglog');
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = dispatch_task(methodName, objectId, varargin)

result = [];

if ~sf('ishandle', objectId)
    return;
end

if is_eml_based_fcn(objectId)
    result = eml_function_man(methodName, objectId, varargin{:});
elseif is_eml_based_chart(objectId)
    result = eml_chart_man(methodName, objectId, varargin{:});
elseif is_eml_script(objectId)
    result = eml_script_man(methodName, objectId, varargin{:});
else
    fprintf(1,'Non-Embedded MATLAB object with id #%d passed to eml_man', objectId);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = jvm_available

persistent sRlt;

if isempty(sRlt)
    sRlt = usejava('jvm') & usejava('awt') & usejava('swing');
end

result = sRlt;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = notify_options(machineId)

result = [];

sr = sfroot;
machine = sr.idToHandle(machineId);
targets = machine.find('-isa','Stateflow.Target');

editor = get_editor;
if isempty(editor)
    return;
end

editor.machineClearOptions(machineId);
for i = 1:length(targets),
    target = targets(i);
    name = target.get('name');
    if strcmp(name,'sfun')
        codeFlagsInfo = target.get('CodeFlagsInfo');
        for codeFlag = codeFlagsInfo
            editor.machineUpdateOption(...
                machineId,...
                sprintf('%s.codeFlags.%s',name, codeFlag.name),...
                codeFlag.value);
        end
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editor = get_editor

persistent sJavaErrorMessage;

editor = [];

if ~jvm_available
    return;
end

if isempty(sJavaErrorMessage)
    try
        editor = com.mathworks.toolbox.eml.EMLEditorApi.editorHandle();
    catch ME
        editor = [];
        sJavaErrorMessage = sprintf(['Embedded MATLAB Editor failed to open:'...
            '%s'],ME.message);
        warning('Stateflow:InternalError',sJavaErrorMessage); %#ok<SPWRN>
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = manage_emldesktop(varargin)

persistent sJavaErrorOccurred;
result = [];
if ~jvm_available
    return;
end

H = com.mathworks.toolbox.eml.EMLEditorApi.editorHandle();
result = H;

if(isempty(sJavaErrorOccurred))
    try
        if nargin > 0
            Action = varargin{1};
            switch (Action)
                case 'status'
                    if ~isempty(H)
                        result = 1;
                    else
                        result = 0;
                    end
                case 'close'
                    if ~isempty(H)
                        H.editorTerminate();
                        H = [];
                        clear H;
                    end
            end
        elseif ~isempty(H)
            iReportEnabled = ~strcmp(sf('Feature', 'EML InferenceReport'), 'Disable');
            H.editorSetInferenceReportEnabled(iReportEnabled);
        end
    catch ME
        sJavaErrorOccurred = sprintf('Error occurred managing Embedded MATLAB Java editor: %s',ME.message);
        warning('Stateflow:InternalError',sJavaErrorOccurred); %#ok<SPWRN>
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = force_close_ui(objectId)

result = [];

hEditor = eml_man('manage_emldesktop');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    hEditor.documentClose(objectId);
end

hEditor = [];
clear hEditor;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_model(filename)

open_system(filename);

result = [];

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_mfile(path)
normalizedPath = strrep(path,'\','/');
if exist(normalizedPath,'file')
    objectId = sf('ScriptCacheGet',normalizedPath);
    eml_man('create_ui',objectId);
    result = objectId;
else
    result = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = simulation_target(machineId)

goto_target(machineId,'sfun');

result = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = rtw_target(machineId)

goto_target(machineId,'rtw');

result = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = eml_help_helper(isEmlChart)

result = [];
try
    if isEmlChart
        % eml_functions_simulink
        sfhelp('em_block_ref');
    else
        % eml_functions_stateflow
        sfhelp('eml_functions_stateflow');
    end
catch errEx %#ok<NASGU>
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result =  eml_functions_help(objectId)

result = [];
try
    if nargin == 0 || is_eml_script(objectId)
        eml_help_helper(true);
    else
        chartId = sf('get', objectId, '.chart');
        eml_help_helper(is_eml_based_chart(chartId));
    end
catch errEx %#ok<NASGU>
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sfhelp_topic(topic)

result = [];
sfhelp(topic);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_stateflow

result = [];
sfhelp('stateflow');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_desk

result = [];
sfhelp('helpdesk');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_eml

result = [];
sfhelp('eML_functions_chapter');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_editor

result = [];

try
    sfhelp('eml_editor');
catch errEx %#ok<NASGU>
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_library_ref

result = [];

try
    sfhelp('embedded_matlab_library_bycategory');
catch errEx %#ok<NASGU>
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = about_stateflow

result = [];
sfabout;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = eml_simevents_help(objectId)
% % DES
result = [];
chartId = sf('get', objectId, '.chart');
errorStatus = eml_des_function_man(chartId, 'help');
if(errorStatus)
    fullName= chart2name(chartId);
    fullName = regexprep(fullName,'/Embedded MATLAB Function','');
    error('EmbeddedMATLAB:UnexpectedError',['Error when displaying the help for ' fullName]);
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = ml_function_exists(fcnName)

existType = exist(fcnName); %#ok<EXIST>
switch (existType),
    case {2, 3, 5, 6},
        result = true;
    otherwise,
        result = false;
end,
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result, objectId] = get_editor_for_opened_object(objectId)
% This function returns the editor handle which has object opened
% If no editor available, or object is not open in editor, return empty.

result = [];

if nargout > 1
    if is_eml_based_chart(objectId)
        ids = eml_based_fcns_in(objectId);
        if ~isempty(ids)
            objectId = ids(1);
        end
    end
end

hEditor = manage_emldesktop;
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    result = hEditor;
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sim_command(machineId, cmd)

result = [];

if machineId == -1
    return
end

modelH = sf('get',machineId,'machine.simulinkModel');

switch(cmd)
    case 'start'
        if strcmp(get_param(modelH,'SimulationStatus'),'paused') && strcmp(cmd,'start')
            set_param(modelH,'SimulationCommand', 'continue');
        else
            eml_start_simulation(machineId);
        end
    case 'stop'
        stop_simulation(machineId);
    otherwise,
        set_param(modelH,'SimulationCommand', cmd);
end

eml_man('update_ui_state',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We don't call start_simulation() if debugging is
% turned off. Instead we shortcut to sfsim('start',...)
% The reason is that start_simulation() calls
% sfdebug('gui,'go'...) which always turns on debugging.
%
function eml_start_simulation(machineId)
hDebugger = sf('get',machineId,'machine.debug.dialog');
if(hDebugger && ishandle(hDebugger) && strcmp( get(hDebugger,'tag'), 'SF_DEBUGGER' ))
    dbInfo = get(hDebugger,'userdata');
    if (strcmp(dbInfo.debuggerStatus,'inactive'))
        sfsim('start', machineId);
    else
        start_simulation(machineId);
    end
else
    start_simulation(machineId);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_debuggable_status(machineId)

hEditor = get_editor();
if ~isempty(hEditor)
    if ~sf('ishandle',machineId)
        % True for scripts which have a bogus "machineId"
        % Whether Debugging is on/off is determined by the document (or script)
        % itself. This just makes it possible at all for scripts to be debuggable.
        % If the script is library MATLAB-file, then debugging should be set to off
        % for that script only, which is handled by the debuggable attribute on
        % the document.
        isOn = true;
    else
        target = sf('get',machineId,'.firstTarget');
        isOn = target_code_flags('get',target,'debug');
    end
    
    if isOn
        isOn = true;
    else
        isOn = false;
    end
    
    hEditor.machineSetDebuggable(machineId, isOn);
    
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_sim_status(machineId)

modelH = sf('get',machineId,'machine.simulinkModel');
result =  get_param(modelH, 'simulationstatus');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_ui_state(machineId,state)
result = [];

hEditor = get_editor();
if isempty(hEditor) || ~hEditor.machineIsOpen(machineId)
    return;
end

if(nargin == 1)
    if sf('ishandle',machineId)
        simStatus = get_sim_status(machineId);
        
        switch(lower(simStatus))
            case 'stopped',
                if sfdebug_paused(machineId)
                    state = 'debug_pause';
                else
                    state = 'idle';
                end
            case 'updating',
                if infer_dbg %sfdebug_paused(machineId)
                    state = 'build_pause';
                else
                    state = 'build';
                end
            case 'initializing',
                state = 'build';
            case 'running',
                if sfdebug_paused(machineId)
                    state = 'debug_pause';
                else
                    state = 'run';
                end
            case 'paused',
                if sfdebug_paused(machineId)
                    state = 'debug_pause';
                else
                    state = 'run_pause';
                end
            case 'terminating',
                state = 'idle';
            case 'external',
                state = 'run';
            case 'library';
                hMachine.setLibrary(true);
            otherwise,
                state = 'error';
        end
    else
        state = 'idle';
    end
end

hEditor.machineSetUIState(machineId,state);

update_debuggable_status(machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = lock_editor(objectId, mode)
% mode: lock/unlock = true/false
result = [];

hEditor = get_editor();
if ~isempty(hEditor)
    if mode % Ensure mode is a logical.
        mode = true;
    else
        mode = false;
    end
    % FIXME: Document or Machine??
    hEditor.documentSetLock(objectId,mode);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = highlight(objectId, sPos, ePos)

result = [];

hEditor = get_editor();
if ~isempty(hEditor)
    if is_eml_based_chart(objectId)
        fcnId = eml_based_fcns_in(objectId);
        if ~isempty(fcnId)
            objectId = fcnId(1);
        end
    end
    hEditor.documentHighlightError(objectId,sPos,ePos);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step(machineId)
result = [];

inferDbgMode = eml_man('infer_dbg');

if inferDbgMode
    sf_debug_exit_trap;
else
    sfdebug('gui','step_over',machineId);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step_in(machineId)
result = [];

sfdebug('gui','step',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step_out(machineId)
result = [];

sfdebug('gui','step_out',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_continue(machineId)
result = [];

inferDbgMode = eml_man('infer_dbg');

if inferDbgMode
    sf('EmlInferDbgGo');
    sf_debug_exit_trap;
else
    sfdebug('gui','go',machineId);
end
clear_active_scripts;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_stop(machineId)
result = [];

sfdebug('gui','stop_debugging',machineId);
clear_active_scripts;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_break(objectId, lineNo)

result = [];

hEditor = get_editor();
if ~isempty(hEditor)
    hEditor.documentDebuggerStopAt(objectId,lineNo);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_sfun_enable(objectId, enabled)
result = [];

targetId = sf('get',objectId,'machine.firstTarget');
while targetId ~= 0
    if strcmp(sf('get',targetId,'target.name'),'sfun')
        codeFlags = target_methods('codeflags',targetId);
        for i = 1:length(codeFlags)
            if strcmp(codeFlags(i).name,'debug')
                codeFlags(i).value = enabled;
            end
        end
        target_methods('setcodeflags',targetId,codeFlags);
        break; % There is only one sfun target
    end
    targetId = sf('get',targetId,'target.linkNode.next');
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_chart_enable(objectId, mode)
% mode: on/off = true/false
result = [];

hEditor = get_editor();
if ~isempty(hEditor)
    if mode % Ensure mode is a logical.
        mode = true;
    else
        mode = false;
    end
    hEditor.documentSetDebuggableChart(objectId,mode);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = mark_clean(objectId)
result = [];

chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');

hEditor = get_editor();
if ~isempty(hEditor)
    hEditor.machineSetDirty(machineId,false);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str, st, en] = find_prototype_str(text)
% Searching for prototype string in text
% function y = foo(x),   returns  "y = foo(x)",
% st: the start position of "function y = foo(x)"
% en: the end position of "function y = foo(x)"

[s e t] = regexp([text 10], '^(?:\s*(%[^\n]*)?\n)*\s*(function)[ \f\t\v]*(\.\.\.[^\n]*\n|.)*?(?:\s*[%\n])', 'once');

if isempty(s)
    % Doesn't match any prototype pattern
    str = '';
    st = 1; % eM java UI updateSubstring require (st,en) to be (1,0)
    en = 0; % if no prototype is present. Otherwise updateSubstring will fail.
    return;
end

pSt = t(2,1);
pEn = t(2,2);
st = t(1,1);
if pSt > pEn
    % Empty second token
    en = t(1,2);
else
    en = t(2,2);
end

str = text(pSt:pEn);

if text(en) == 10
    % We want to preserve the ending newline, so that it won't be eaten
    % out by replacing with updated prototype.
    en = en - 1;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_diagram(objectId)
result = [];
chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
modelH = sf('get',machineId,'machine.simulinkModel');
set_param(modelH, 'SimulationCommand','Update')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = check_symbol(objectId, symbolName)
result = [];

try
    resolvedId = sf('EmlResolveSymbol', objectId, symbolName);
catch errEx %#ok<NASGU>
    resolvedId = 0;
end

if (resolvedId ~= 0)
    hEditor = get_editor();
    if ~isempty(hEditor)
        hEditor.documentSymbolChecked(objectId, symbolName);
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = browse_symbol(objectId, symbolName)
result = [];

try
    resolvedId = sf('EmlResolveSymbol', objectId, symbolName);
catch errEx %#ok<NASGU>
    resolvedId = 0;
end

if (resolvedId ~= 0)
    sf('Open', resolvedId);
else
    hEditor = get_editor();
    if ~isempty(hEditor)
        hEditor.documentGotoSymbolFirstExistence(objectId, symbolName);
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = request_data_scope_change(objectId, dataName, text, caretPosition)
result = [];

hEditor = get_editor();
if ~isempty(hEditor)
    [~, posBegin, posEnd] = find_prototype_str(text);
    if caretPosition >= posBegin && caretPosition <= posEnd
        chartId = sf('get',objectId,'state.chart');
        sr = sfroot;
        uddChartId = sr.find('id',chartId);
        data = uddChartId.find('-isa','Stateflow.Data');
        for i = 1:numel(data)
            if strcmp(data(i).name, dataName)
                % We found something, so we'll notify EML
                hEditor.documentDataScopeChangeReply(objectId,...
                    dataName, data(i).scope);
                break;
            end
        end
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_data_scope(objectId, dataName, dataScope)
result = [];

chartId = sf('get',objectId,'state.chart');
sr = sfroot;
uddChartId = sr.find('id',chartId);
data = uddChartId.find('-isa','Stateflow.Data');
for i = 1:numel(data)
    if strcmp(data(i).name, dataName)
        % We found the name so change the scope...
        data(i).scope = dataScope;
        break;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = infer_dbg(varargin)

persistent status;

if isempty(status)
    status = 0;
end

switch nargin
    case 1
        status = varargin{1};
        
        sf('EmlInferDbgSetEnable', status);
        
        if manage_emldesktop('status')
            hEmlEditor = manage_emldesktop;
            uiObjList = double(hEmlEditor.cachedObjectIds());
            for i = 1:length(uiObjList)
                refresh_breakpoints_display(uiObjList(i));
            end
        end
    case 2
        status = varargin{1};
        refreshBreakPointStatus =  varargin{2};
        sf('EmlInferDbgSetEnable', status);
        if(refreshBreakPointStatus)
        end
    otherwise
        % do nothing
end

result = status;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = refresh_breakpoints_display(objectId, varargin)
% objectId, <breakpoints>

result = [];

inferBreakPoints = [];
if nargin > 1
    bkpts = varargin{1};
else
    bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, infer_dbg);
    bkpts = sf('get', objectId, bkptPropStr);
    inferBreakPoints = sf('get', objectId,'state.eml.inferBkpts');
end

hEditor = get_editor();
if ~isempty(hEditor)
    if(infer_dbg)
        hEditor.documentSetBuildBreakpoints(objectId,inferBreakPoints);
    end
    hEditor.documentSetRunBreakpoints(objectId,bkpts);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = register_breakpoint(objectId, lineNo, regValue, debugMode)
% if debugMode == 0 register  RunTime breakpoints
% if debugMode == 1 register  Inference breakpoints

if nargin < 4
    debugMode = 0;
end

bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, debugMode);
brkpts = sf('get', objectId, bkptPropStr);
if regValue
    if isempty(find(brkpts == lineNo, 1))
        brkpts = [brkpts, lineNo];
    end
else
    brkpts(brkpts == lineNo) = [];
end
sf('set', objectId, bkptPropStr, brkpts);

result = brkpts;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = clear_all_breakpoints(objectId)

result = [];

bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, infer_dbg);
sf('set', objectId, bkptPropStr, []);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = clear_all_infer_and_runtime_breakpoints(objectId)
result = [];
sf('set', objectId,'state.eml.breakpoints',[])
sf('set', objectId,'state.eml.inferBkpts',[])

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_explorer(objectId)

result = [];
sf('Explr');
objId = eml_fcn_source(objectId);
if ~is_eml_script(objectId)
    sf('Explr', 'VIEW', objId);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectId = eml_fcn_source(objectId)

if ~is_eml_based_chart(objectId) && ~is_eml_script(objectId)
    % must be eml function
    chartId = sf('get', objectId, '.chart');
    if is_eml_based_chart(chartId)
        objectId = chartId;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clear_active_scripts
% When debugger is stopped we need to update all script objects
% to notify that there is no active machine.
hEditor = get_editor();
allScripts = sf('find','all','~script.activeMachineId',-1);
for objectId = allScripts
    sf('set',objectId,'script.activeMachineId',-1);
    if ~isempty(hEditor)
        hEditor.documentChangeActiveInstance(objectId,-1);
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = close_all_scripts

result = [];
%during_close_ui(1);
allScripts = sf('find','all','~script.script',[]);
for objectId = allScripts
    hEditor = eml_man('get_editor_for_opened_object', objectId);
    if ~isempty(hEditor)
        eml_man('update_data',objectId);
        %update_layout_data(objectId);
        hEditor.documentClose(objectId);
    end
end
return;

function result = rtw_highlight_code(objectId, lineNo)
result = rtw_highlight_code_helper(objectId, lineNo, 'rtw');

function result = hdl_highlight_code(objectId, lineNo)
result = rtw_highlight_code_helper(objectId, lineNo, 'slhdlc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = rtw_highlight_code_helper(objectId, lineNo, target)

result = [];

root = sfroot;
handle = root.idToHandle(objectId);

% return chart handle for EML Function Block and Truth Table Block states
if isempty(handle)
    handle = idToHandle(sfroot, getChartOf(objectId));
end

% get the SSId from the handle
objectSSId = handleTossId(handle);
if isempty(objectSSId)
    return;
end

% make SSId with line number as auxInfo
[blockPath, ssIdNumber] = traceabilityManager('parseSSId', objectSSId);
auxInfo = num2str(lineNo + 1);
SSId = traceabilityManager('makeSSId', blockPath, ssIdNumber, auxInfo);

if strcmp(target,'slhdlc')
    traceabilityManager('hdlTraceObject', SSId);
else
    traceabilityManager('rtwTraceObject', SSId);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLibrary = machine_is_library(machineId)
if machineId == -1
    isLibrary = false;
    return;
end
modelH = sf('get',machineId,'machine.simulinkModel');

isLibrary = strcmp(lower(get_param(modelH,'BlockDiagramType')), 'library'); %#ok
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_editor(parentMachineId, activeMachineId, objectId, inDebugging)
result = [];

if ~eml_man('jvm_available');
    error('EmbeddedMATLAB:UnexpectedError','%s','The Embedded MATLAB editor requires Java Swing and AWT components. One of these components in missing.');
end

hEditor =  eml_man('manage_emldesktop');
if(isempty(hEditor))
    error('EmbeddedMATLAB:UnexpectedError','%s','Embedded MATLAB editor could not be initialized.');
end

parentIsLibrary = machine_is_library(parentMachineId);
activeIsLibrary = machine_is_library(activeMachineId);

if is_eml_based_fcn(objectId)
    chartId = sf('get',objectId,'state.chart');
    isBlock = is_eml_based_chart(chartId);
    isTruthTable = is_eml_truth_table_chart(chartId);
    isDESVariant = isBlock && sf('get',objectId,'.eml.isDESVariant');
    textSrc = 'state.eml.script';
else
    isBlock = false;
    isTruthTable = false;
    isDESVariant = false;
    textSrc = 'script.script';
end

machineId = parentMachineId;
hEditor.machineOpen(parentMachineId,parentIsLibrary);
hEditor.machineOpen(activeMachineId,activeIsLibrary);

layout = sf('get', objectId, 'state.eml.editorLayout');
if(isempty(layout) || length(layout) ~= 4)
    layout = [10, 5, 750, 500];
end


if inDebugging
    opened = hEditor.documentOpenFromDebugger(activeMachineId,...
        machineId,...
        objectId, ...
        isBlock, ...
        isTruthTable, ...
        isDESVariant, ...
        '',...
        '', ...
        sf('get',objectId,textSrc),...
        layout(1), layout(2), layout(3), layout(4));
else
    opened = hEditor.documentOpen(activeMachineId,...
        machineId,...
        objectId, ...
        isBlock, ...
        isTruthTable, ...
        isDESVariant, ...
        '',...
        '', ...
        sf('get',objectId,textSrc),...
        layout(1), layout(2), layout(3), layout(4));
end

if ~opened
    error('EmbeddedMATLAB:UnexpectedError','Failed to open a new Embedded MATLAB editor pane.');
end

eml_man('set_title',objectId);
% Mark breakpoints
bpStr = eml_man('get_bkpt_prop_str',objectId);
bkpts = sf('get', objectId, bpStr);
inferBkpts = sf('get', objectId, 'state.eml.inferBkpts');

hEditor.documentSetRunBreakpoints(objectId,bkpts);
hEditor.documentSetBuildBreakpoints(objectId,inferBkpts);

% In the case where all editor windows were closed in the middle of a
% debugging session; this reinforms the editor that such is the case.
% It is wise to make sure the UI state is correct at this critical
% juncture in all cases.
update_ui_state(activeMachineId);

if sfdebug_paused(activeMachineId)
    [id,lineNo] = sfdebug_get_linenum(activeMachineId);
    if(id == objectId && lineNo ~= 0)
        eml_man('debugger_break',objectId,lineNo);
    end
end

return;
