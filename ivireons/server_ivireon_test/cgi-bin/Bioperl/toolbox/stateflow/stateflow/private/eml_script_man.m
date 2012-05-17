function result = eml_script_man(methodName, objectId, varargin)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $  $Date: 2009/03/31 00:29:27 $

result = [];

% Input object should be Stateflow eML script
if ~sf('ishandle',objectId) || ~is_eml_script(objectId)
    return;
end

try
    switch(methodName)
        case {'close_ui', 'set_title', 'save_model', ...
              'print', 'model_dirty', 'update_data', 'script_dirty', 'script_clean'}
            result = feval(methodName, objectId);
        %case {'debugger_step', 'debugger_stop', 'debugger_continue','get_eml_prototype'}
        %case {'save_model_as','update_ui','update_layout_data','model_dirty'}
            % These methods need more thoughts
        %    result = feval(methodName, objectId, varargin{:});
        case {'create_ui', 'refresh_editor', 'query_symbol', 'save_mfile_as'}
            result = feval(methodName, objectId, varargin{:});
        case {'get_bkpt_prop_str','close_all_ui'}
            result = feval(methodName, varargin{:});
        case {'new_model'}
            result = feval(methodName);
        otherwise,
            errStr = sprintf('Unknown methodName "%s" passed to eml_script_man', methodName);
            %error(errStr);
            disp(errStr);
    end
catch ME
    str = sprintf('Error calling eml_script_man(%s): %s',methodName,ME.message);
    if(~strcmp(methodName,'create_ui'))
        construct_error(objectId, 'Embedded MATLAB', str, 0);
        slsfnagctlr('ViewNaglog');
    else
        str = sprintf('Error opening the Embedded MATLAB editor:\n%s\n',clean_error_msg(ME.message));
        disp(str);
        errordlg(str,'Embedded MATLAB Editor Creation Failed','replace');
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(objectId, inDebugging, instanceHandle)

if nargin < 2
    inDebugging = 0;
end

result = [];
if ~eml_man('jvm_available');
    error('EmbeddedMATLAB:UnexpectedError','The Embedded MATLAB editor requires Java Swing and AWT components. One of these components in missing.');
end

hEditor =  eml_man('manage_emldesktop');
if(isempty(hEditor))
    error('EmbeddedMATLAB:UnexpectedError','The Embedded MATLAB editor could not be initialized.');
end

activeMachineId = sf('get',objectId,'script.activeMachineId');    
activeIsLibrary = machine_is_library(activeMachineId);

if inDebugging && activeIsLibrary
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

  scriptMachineId = -1;
  eml_man('open_editor',scriptMachineId,activeMachineId,objectId,inDebugging);
end

libName = sf('get',objectId,'script.libName'); 

hEditor.documentChangeActiveInstance(objectId, activeMachineId);

% In developer mode, EML editor can open, edit and debug any .m file under matlab/toolbox.
isDeveloper = logical(sf('Feature','Developer'));
if isDeveloper
    hEditor.editorSetLibraryMFilesEditable(true);
    hEditor.documentSetLibraryMFile(objectId, false);
    hEditor.documentSetDebuggableChart(objectId, true);
else 
    hEditor.editorSetLibraryMFilesEditable(false);
    hEditor.documentSetLibraryMFile(objectId,~isempty(libName));
    hEditor.documentSetDebuggableChart(objectId,isempty(libName));
end

eml_man('update_ui_state',-1,'idle');
eml_man('update_ui_state',activeMachineId);

result = hEditor;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLibrary = machine_is_library(machineId)
if machineId == -1
    isLibrary = false;
    return;
end
modelH = sf('get',machineId,'machine.simulinkModel');

isLibrary = strcmpi(get_param(modelH,'BlockDiagramType'), ...
                     'library');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_title(objectId)
% Refresh eML editor title
result = [];

hEditor = eml_man('get_editor_for_opened_object', objectId);
if ~isempty(hEditor)
  [titleString, shortName] = create_title_string(objectId);
  hEditor.documentSetTitle(objectId,titleString);
  hEditor.documentSetShortName(objectId,shortName);      
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = refresh_editor(objectId)

result = [];
hEditor = eml_man('get_editor');
if ~isempty(hEditor) && ...
   hEditor.documentIsOpen(objectId) && ...
   ~hEditor.documentIsDirty(objectId)
    script = sf('get', objectId, 'script.script');
    hEditor.documentSetText(objectId, script, 0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [titleString, shortName] = create_title_string(objectId)

filePath = sf('get', objectId, 'script.filePath');
titleString = ['Script: ' filePath];
shortName = sf('get', objectId, '.name');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = close_ui(objectId)

result = [];
%during_close_ui(1);

hEditor = eml_man('get_editor_for_opened_object', objectId);
if ~isempty(hEditor)
    update_data(objectId);
    %update_layout_data(objectId);
    hEditor.documentClose(objectId);
end

hEditor = [];
clear hEditor;

%during_close_ui(0);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = query_symbol(objectId, pos)
result = eml_query_symbol(objectId,pos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = print(objectId)

update_data(objectId); % Put print in eml_man later
htmlBuf = state2html(objectId);
jobName = ['(Embedded MATLAB) ' sf('get', objectId, '.name')];
result = print_html_str(htmlBuf, jobName);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = save_model(objectId)

result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    newScript = char(hEditor.documentGetText(objectId));
    sf('set', objectId, 'script.script', newScript);
    sf('set', objectId, 'script.timeStamp1', 0);
    sf('set', objectId, 'script.timeStamp2', 0);
    
    filePath = sf('get', objectId, 'script.filePath');
    fid = fopen(filePath,'w');
    if fid == -1
        error('EmbeddedMATLAB:CantOpenFileForWrie','Can not open file for writing: %s', filePath);
    end
    fwrite(fid, newScript);
    fclose(fid);
      
    hEditor.documentSetDirty(objectId,false);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = save_mfile_as(objectId, fullPath)

result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    script = sf('get', objectId, 'script.script');
    fid = fopen(fullPath,'w');
    fwrite(fid, script);
    fclose(fid);
    newObjectId = eml_man('open_mfile',fullPath);
    hEditor.documentSetDirty(newObjectId,false);
    result = newObjectId;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_bkpt_prop_str(varargin)

result = [];
inferDbgMode = [];

if nargin > 0
    inferDbgMode = varargin{1};
else
    inferDbgMode = eml_man('infer_dbg');
end

if inferDbgMode
    result = 'script.inferBkpts';
else
    result = 'script.breakpoints';
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_dirty(objectId)

result = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = script_dirty(objectId)

result = [];
sf('set',objectId,'script.dirty',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = script_clean(objectId)

result = [];
sf('set',objectId,'script.dirty',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(objectId)

result = [];

% update data from editor UI
hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    oldScript = sf('get',objectId,'script.script');
    newScript = char(hEditor.documentGetText(objectId));
    if ~isequal(oldScript, newScript)
        sf('TurnOffEMLUIUpdates',1);
        sf('set',objectId,'script.script',newScript);
        timeStamp1 = sf('get', objectId, 'script.timeStamp1');
        sf('set',objectId,'script.timeStamp1', timeStamp1+1);
        sf('TurnOffEMLUIUpdates',0);
    end
end
result = 1;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = new_model()

result = [];
open_system(new_system);

