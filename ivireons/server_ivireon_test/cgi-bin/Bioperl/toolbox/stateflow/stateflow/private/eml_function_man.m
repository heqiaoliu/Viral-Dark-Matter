function result = eml_function_man(methodName, objectId, varargin)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.32 $  $Date: 2010/05/20 03:36:00 $

result = [];

% Input object should be Stateflow eML function
if ~sf('ishandle',objectId) || ~is_eml_based_fcn(objectId)
    return;
end

try
    switch(methodName)
        case {'close_ui', 'set_title','compile','get_eml_prototype',}
            result = feval(methodName, objectId);
        case {'update_active_instance', 'update_data', 'update_ui', 'sync_prototype', 'query_symbol'}
            set_title(objectId);
            result = feval(methodName, objectId, varargin{:});
        case {'goto_sf_editor', 'update_layout_data', 'model_dirty', 'new_model','print'}
            set_title(objectId);
            result = feval(methodName, objectId);
        case {'update_script_prototype', 'create_ui', 'set_blk_handle'}
            result = feval(methodName, objectId, varargin{:});
        case {'get_bkpt_prop_str'}
            result = feval(methodName, varargin{:});
        case 'save_model'
            set_title(objectId);
            machine = sf('get',sf('get',objectId,'.chart'),'.machine');
            % sfsave will do all eML, truthtable data updation from editor
            sfsave(machine,[], 1);
        case 'save_model_as'
            set_title(objectId);
            machine = sf('get',sf('get',objectId,'.chart'),'.machine');
            % sfsave will do all eML, truthtable data updation from editor
            sfsave(machine,sf('get',machine,'.name'), 1);
        case 'debugger_chart_set_enabled'
            feval(methodName, objectId, varargin{:});
        case 'export_to_m'
            set_title(objectId);
            update_data(objectId);
            % NOT DONE YET
        case 'open_compilation_report'
            eml_report_manager('open', sf('get', objectId, '.chart'), varargin{1});
        otherwise,
            fprintf(1,'Unknown methodName %s passed to eml_function_man', methodName);
    end
catch ME
    str = sprintf('Error calling eml_function_man(%s): %s',methodName,ME.message);
    if(~strcmp(methodName,'create_ui'))
        construct_error(objectId, 'Embedded MATLAB', str, 0);
        slsfnagctlr('ViewNaglog');
    else
        str = sprintf('Error opening the Embedded MATLAB editor:\n%s\n',clean_error_msg(ME.message));
        disp(str);
        errordlg(str,'Embedded MATLAB Editor Creation Failed','replace');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_eml_prototype(objectId) 

script = sf('get', objectId, 'state.eml.script');
result = eml_man('find_prototype_str', script);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = print(objectId) 

update_data(objectId);
htmlBuf = state2html(objectId);
jobName = ['(Embedded MATLAB) ' sf('get', objectId, '.name')];
result = print_html_str(htmlBuf, jobName);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLibrary = machine_is_library(machineId)
modelH = sf('get',machineId,'machine.simulinkModel');

isLibrary = strcmpi(get_param(modelH,'BlockDiagramType'),'library');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_blk_handle(objectId, blockH)

result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  hEditor.documentSetBlkHandle(objectId, blockH);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(objectId) 

result = [];

hEditor = eml_man('manage_emldesktop');

if isempty(hEditor) 
  return;
end

if hEditor.documentIsOpen(objectId)
  chartId = sf('get',objectId,'state.chart');
  activeMachineId = actual_machine_referred_by(chartId);
  
  % Make sure the active machine is "open" in the editor.
  if ~hEditor.machineIsOpen(activeMachineId)
    hEditor.machineOpen(activeMachineId, ...
                        machine_is_library(activeMachineId));
  end
  hEditor.documentChangeActiveInstance(objectId,activeMachineId);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(objectId, inDebugging, instanceHandle)

if ~eml_man('jvm_available');
    error('EmbeddedMATLAB:UnexpectedError','%s','The Embedded MATLAB editor requires Java Swing and AWT components. One of these components in missing.');
end

hEditor =  eml_man('manage_emldesktop');
if(isempty(hEditor))
    error('EmbeddedMATLAB:UnexpectedError','%s','Embedded MATLAB editor could not be initialized.');
end

if nargin < 2
    inDebugging = 0;
end

chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
isLibrary = machine_is_library(machineId);
activeMachineId = actual_machine_referred_by(chartId);

if inDebugging && isLibrary
    sfId = sl('get',instanceHandle,'UserData');
    currentMachineId = sf('get',sfId,'.machine');
    if currentMachineId ~= activeMachineId
        open_system(instanceHandle);
    end
end

if hEditor.documentIsOpen(objectId)
  % Already open. Bring it to front.
  if inDebugging
      hEditor.documentToFrontFromDebugger(objectId);
  else
      hEditor.documentToFront(objectId,true);
  end
else
  % Create the a new document window for this id.
  eml_man('open_editor',machineId,activeMachineId,objectId,inDebugging);
  if(sf('get',chartId,'chart.iced') || sf('get',chartId,'chart.locked'))
    eml_man('lock_editor',objectId,1);
  end  

  if(sf('get',chartId,'chart.eml.noDebugging'))
    eml_man('debugger_chart_enable',objectId,0);
  else
    eml_man('debugger_chart_enable',objectId,1);
  end

  eml_man('update_ui_state',activeMachineId);  
end

result = hEditor;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = during_close_ui(varargin)
% G157881. In editor closing time, don't try to update UI

persistent status;

if isempty(status)
    status = 0;
end

if nargin > 0
    status = varargin{1};
end

result = status;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = close_ui(objectId) 

result = [];

during_close_ui(1);

hEditor = eml_man('manage_emldesktop');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  update_data(objectId);
  update_layout_data(objectId);
  hEditor.documentClose(objectId);
end

clear hEditor;

during_close_ui(0);

% Close the data event manager if there is one open
chart = sf('get', objectId, '.chart');
if is_eml_based_chart(chart)
    sf_de_manager('close', chart);
end
% Close the compilation report
if sf('Feature', 'EML InferenceReport')
    eml_report_manager('close', chart); % Close inference report
end
    
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(objectId,varargin)

result = [];
prototypeChanged = false;

if nargin > 1
    switch varargin{1}
        case 'script'
            oldScript = sf('get',objectId,'state.eml.script');
            newScript = char(varargin{2});
            if ~isequal(oldScript, newScript)
                prototypeChanged = is_prototype_changed(oldScript,newScript);
                sf('TurnOffEMLUIUpdates',1);
                sf('set',objectId,'state.eml.script',newScript);
                sf('TurnOffEMLUIUpdates',0);
            end
        otherwise
            error('EmbeddedMATLAB:UnexpectedError','Unknown data update mode');
    end
else  
    % update data from eML editor UI
    hEditor = eml_man('get_editor');
    if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
        oldScript = sf('get',objectId,'state.eml.script');
        newScriptxx = hEditor.documentGetText(objectId);
        newScript = char(newScriptxx);
        if ~isequal(oldScript, newScript)
            prototypeChanged = is_prototype_changed(oldScript,newScript);
            sf('TurnOffEMLUIUpdates',1);
            sf('set',objectId,'state.eml.script',newScript);
            sf('TurnOffEMLUIUpdates',0);
        end
    end
end

% % DES
if(sf('get',objectId,'.eml.isDESVariant') && prototypeChanged)         
    chartId = sf('get', objectId,'.chart');
    errorStatus = eml_des_function_man(chartId,'update');
    if(errorStatus)
        report_simevents_error('update')
    end
end

% %%%% EMM - 2/22/2003 - The following code is for BAT and internal
% %%%                   testing of eML language and run-time library
% %%%                   scripts.
eml_evalin_matlab('eval',objectId);
%%%

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = compile(objectId) 

chartId = sf('get', objectId, '.chart');
machineId = sf('get',chartId,'chart.machine');
autobuild_driver('rebuildall',machineId,'sfun','yes');
% update status bar
result = 'ready';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = new_model(objectId) 

result = [];
chartId = sf('get', objectId, '.chart');
if(is_eml_based_chart(chartId))
    open_system(new_system);
else
    sfnew;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_bkpt_prop_str(varargin)

if nargin > 0
    inferDbgMode = varargin{1};
else
    inferDbgMode = 0;
end

if inferDbgMode
    result = 'state.eml.inferBkpts';
else
    result = 'state.eml.breakpoints';
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_title(objectId)
% Refresh eML editor title
result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  [titleString, shortName] = create_title_string(objectId);
  hEditor.documentSetTitle(objectId,titleString);
  hEditor.documentSetShortName(objectId,shortName);  
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [titleString, shortName] = create_title_string(objectId)
% the title string must be appropriately
% constructed for eml fcns and eml blocks
chartId = sf('get',objectId,'.chart');

[fullName,shortName] = chart2name(chartId);

if(is_eml_based_chart(chartId))
    % % DES
    if(is_simevents_eml_script(chartId))
        % Remove the Embedded MATLAB Function block from the title
        [errorStatus, titleString] = eml_des_function_man(chartId,'title',fullName);
        if(errorStatus)
            report_simevents_error('title');
        end
    else
        titleString = ['Block: ' fullName];
    end
else
    titleString = ['Stateflow (Embedded MATLAB) ' fullName,'.',sf('FullNameOf',objectId,chartId,'.')];
    shortName = sf('get', objectId, '.name');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_ui(objectId, varargin) 
result = [];
if nargin < 2
  return;
end

hEditor = eml_man('get_editor');
if ~isempty(hEditor)  
  switch varargin{1}
   case 'script'
    hEditor.documentSetText(objectId,varargin{2},false);
   otherwise
    return;
  end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = query_symbol(objectId, pos) 
result = eml_query_symbol(objectId,pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_layout_data(objectId)

result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  layout = double(hEditor.documentLayout(objectId));
  sf('set', objectId, 'state.eml.editorLayout', layout);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_dirty(objectId) 

result = [];

chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
modelH = sf('get',machineId,'machine.simulinkModel');

sf('set',machineId,'machine.dirty',1);
sf('set',chartId,'chart.dirty',1);
if(strcmp(get_param(modelH,'Lock'),'off'))
  set_param(modelH,'dirty','on');
end

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.machineIsOpen(machineId)
  hEditor.machineSetDirty(machineId,true);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sync_prototype(objectId, dirLabelToScript) 

result = [];

% Turn off synchronize becase we are alreay in it
sf('TurnOffPrototypeSync',1);

if (dirLabelToScript)
    % The sync direction is from label string to eML script

    % Make sure Stateflow get updated eML script from eML editor.
    update_data(objectId);

    newLabelStr = sf('get', objectId, 'state.labelString');
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str',script);

    if isempty(pStr)
        % Fix function prototype in script
        update_script_prototype(objectId, script, ['function ' regexprep(newLabelStr, '\(\)$', '') 10], st,en);
    elseif ~function_prototype_utils('compare', newLabelStr, pStr)
        % Update function prototype in script
        update_script_prototype(objectId, script, ['function ' regexprep(newLabelStr, '\(\)$', '')], st,en);
    end
else
    % The sync direction is from eML script to label string
    oldLabelStr = sf('get', objectId, 'state.labelString');
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str',script);

    if isempty(pStr)
        % Fix function prototype in script
        update_script_prototype(objectId, script,  ['function ' regexprep(oldLabelStr, '\(\)$', '') 10], st,en);
    %elseif ~function_prototype_utils('compare', oldLabelStr, pStr)
    elseif ~strcmp(oldLabelStr, pStr)
        % Update function prototype in Stateflow

        % Attempt to set Stateflow block with new labelString
        % Read back the auto corrected label string.
        sf('set', objectId, 'state.labelString', pStr);
        corrLabelStr = sf('get', objectId, 'state.labelString');

        if ~function_prototype_utils('compare', corrLabelStr, pStr)
            % If prototype get corrected, correct it in script too
            update_script_prototype(objectId, script, ['function ' regexprep(corrLabelStr, '\(\)$', '')], st,en);
        end
    end
end

% Restore synchronize function prototype
sf('TurnOffPrototypeSync',0);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_script_prototype(objectId, script, newPrototypeStr, st, en)

result = [];

newScript = [script(1:st-1) newPrototypeStr script(en+1:end)];
sf('TurnOffEMLUIUpdates',1);
sf('set', objectId, 'state.eml.script', newScript);
sf('TurnOffEMLUIUpdates',0);

if ~during_close_ui
  hEditor = eml_man('get_editor');
  if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    hEditor.documentUpdateSubstring(objectId,st,en,newPrototypeStr);
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_chart_set_enabled(objectId, enabled)

result = [];

chart = sf('get',objectId,'.chart');
if enabled
    noDebugging = 0;
else
    noDebugging = 1;
end
%
% The following call will issue a callback to debugger_chart_enable(...)
% updating the state of the editor.
%
sf('set',chart,'chart.eml.noDebugging',noDebugging);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % DES
function result = is_simevents_eml_script(chartId)
fcnId = sf('Private','eml_based_fcns_in',chartId);
result = sf('get',fcnId,'.eml.isDESVariant');
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % DES
function result = is_prototype_changed(oldScript,newScript)
oldPStr = eml_man('find_prototype_str',oldScript); 
newPStr = eml_man('find_prototype_str',newScript); 
result = ~strcmp(oldPStr,newPStr);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % DES
function report_simevents_error(action) 
errorMsg = ['Error when calling eml_des_function_man:' action '.' char(10) 'SimEvents installation is required for using this functionality'];
error('EmbeddedMATLAB:UnexpectedError',errorMsg);

