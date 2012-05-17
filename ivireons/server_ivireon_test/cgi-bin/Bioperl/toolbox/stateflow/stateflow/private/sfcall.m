function sfcall( command, ~ )
% Stateflow Callback dispatcher

%	E. Mehran Mestchian
%	Jay R. Torgerson
%   Copyright 1995-2010 The MathWorks, Inc.
%  $Revision: 1.75.4.25 $  $Date: 2010/05/20 03:36:28 $
if nargin>1, return; end

if nargin == 1,
    disp(command);
end;

obj = safe_gcbo_l;

%
% Resolve machine from chart and the active instnace
%
chart=get(safe_gcbf_l, 'UserData');
fig = sf('get', chart, '.hg.figure');

machine = actual_machine_referred_by(chart);

ted_the_editors(machine);
GET = sf('method','get');

if isempty(chart), return; end
if length(chart)~=1, error('Stateflow:UnexpectedError','Bad userdata in SFCHART'); end

status = findobj(fig,'type','uicontrol','style','text');

% Let all handles be visible for the switch below
shh = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'On');

try
    switch get(obj,'Type')
        case 'figure',
            switch command
                otherwise
                    if nargin>0
                        set(status,'String',['FIGURE callback ''',command, ''' is TBD!']);
                    else
                        disp('FIGURE callback is TBD!');
                    end
            end
        case 'text'
            set(status,'String','text callback is TBD!');
        case 'patch'
            set(status,'String','patch callback is TBD!');
        case 'uicontrol'
            switch obj
                case findobj(fig,'Type','uicontrol','Style','popupmenu')
                    zoom_size( chart, obj );
                case findobj(fig,'Type','uicontrol','Style','slider')
                case sf(GET,chart,'.hg.vertSlide')
                    vertical_slide( chart, obj );
                case findobj(fig,'Type','uicontrol','Style','slider')
                case sf(GET,chart,'.hg.horzSlide')
                    horizontal_slide( chart, obj );
                otherwise
                    set(status,'String',['UICONTROL ''',get(obj,'Tag'),''' callback is TBD!']);
            end;
        case 'uimenu'
            menuLabelStr = get(obj,'Label');
            menuLabelStr( find(menuLabelStr=='&') ) = [];
            switch menuLabelStr
                case 'New Model',               sfnew;
                case 'Open Model...',           sfopen;
                case 'Save Model',              ui_save(machine, false);
                case 'Save Model As...',        ui_save(machine, true);
                case 'Get Latest Version...' % PC only command
                    rcs_get_latest_version(machine);
                case 'Check Out...' % Code different on PC and Unix
                    rcs_check_out(machine);
                case 'Check In...' % Code different on PC and Unix
                    rcs_check_in(machine);
                case 'Undo Check-Out...' % Code different on PC and Unix
                    rcs_undo_check_out(machine);
                case 'Add to Source Control...' % PC only command
                    rcs_add_to_source_control(machine);
                case 'Remove from Source Control...' % PC only command
                    rcs_remove_from_source_control(machine);
                case 'History...' % PC only command
                    rcs_history(machine);
                case 'Differences...' % PC only command
                    rcs_differences(machine);
                case 'Properties...' % PC only command
                    rcs_properties(machine);
                case 'Start Source Control System...' % PC only command
                    rcs_start_source_control_system;
                case 'Close',                   sfclose(chart);
                case 'Close All Charts',        sfclose(sf('get',machine,'.charts'));
                case 'Chart Properties',        dlg_open(chart);
                case 'Machine Properties',      dlg_open(machine);
                case 'Exit MATLAB',             matlab_exit;
                case 'Cut',                     sf('Cut', chart);
                case 'Copy',                    sf('Copy', chart);
                case 'Paste',                   sf('Paste', chart);
                case 'Undo',					sf('Undo', chart);
                case 'Redo',					sf('Redo', chart);
                case 'Print Book...',           rg(chart,'ps');
                case 'Print Details...',        rptgen_sl.slbook('-showdialog',sf('get', chart,'chart.viewObj'));
                case 'To Printer',              sfprint(chart, 'default', 'printer', 0, 1);
                case 'PostScript',              sfprint(chart, 'ps',   'promptForFile',0);
                case 'Color PostScript',        sfprint(chart, 'psc',  'promptForFile',0);
                case 'Encapsulated PostScript', sfprint(chart, 'eps',  'promptForFile',0);
                case 'Tiff',                    sfprint(chart, 'tiff', 'promptForFile',0);
                case 'Jpeg',                    sfprint(chart, 'jpg',  'promptForFile',0);
                case 'Png',                     sfprint(chart, 'png',  'promptForFile',0);
                case 'To Figure',               sfprint(chart, 'hg',   'figure', 0);
                case 'Print...',                sf_hier_print(chart);
                case 'Print Setup...',          sfprint(chart, 'setup');
                case 'Meta',                    sfprint(chart, 'meta',   'clipboard',0);
                case 'Bitmap',                  sfprint(chart, 'bitmap', 'clipboard',0);
                case 'Explore',                 view_in_explorer(chart);
                case 'Back',                    sf('BackView', chart);
                case 'Forward',                 sf('ForwardView', chart);
                case 'Go To Parent',            sf('UpView', chart);
                case 'Model Explorer',          view_in_explorer(chart);
                case 'Debug...',                goto_debugger(chart);
                case 'Find...',                 sfsrch('create', chart);
                case 'Search  Replace...',     sfsnr(chart);
                case 'Parse',                   parse_this(machine);
                case 'Parse Diagram',           parse_this(chart);
                case 'Help',
                case 'Editor',                  sfhelp;
                case 'Stateflow Help',          sfhelp('stateflow');
                case 'Help Desk',               sfhelp('helpdesk');
                case 'About Stateflow',         sfabout;
                case 'Terms of use...',
                    try
                        edit ([matlabroot, '/license.txt']);
                    catch
                        disp(xlate('Error displaying terms...license file not found.'));
                    end
                case 'Patents...',
                    try
                        edit ([matlabroot, '/patents.txt']);
                    catch
                        disp(xlate('Error displaying patent information...patents file not found.'));
                    end
                case 'Documentation...',        sfhelp('doc');
                case 'Browser',                 sfprops(chart,sf('Lookup',chart));
                case 'Style...',                sfstyler(chart);
                case 'Highlighting Preferences...',DAStudio.Dialog(Stateflow.SyntaxColorMap);
                case 'OR',                      sf('set',sf('SelectedObjectsIn',chart),'state.type','OR');
                case 'AND',                     sf('set',sf('SelectedObjectsIn',chart),'state.type','AND');
                case 'History',                 sf('set',sf('SelectedObjectsIn',chart),'junction.type','HISTORY');
                case 'Connective',              sf('set',sf('SelectedObjectsIn',chart),'junction.type','CONNECTIVE');
                case 'Plain',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','PLAIN');
                case 'Split',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','SPLIT');
                case 'Merge',                   sf('set',sf('SelectedObjectsIn',chart),'junction.type','MERGE');
                    % data and events are differentiated by the space at the end of
                    % the menu item for events.  (Barf)
                case 'Local... ',               id = new_event(chart, 'LOCAL'); sfdlg(id,1);
                case 'Input from Simulink... ', id = new_event(chart,'INPUT'); sfdlg(id,1);
                case 'Output to Simulink... ',  id = new_event(chart, 'OUTPUT');sfdlg(id,1);
                case 'Local...',                id = new_data(chart); sfdlg(id,1);
                case 'Input from Simulink...',  id = new_data(chart,'INPUT');  sfdlg(id,1);
                case 'Output to Simulink...',   id = new_data(chart,'OUTPUT');sfdlg(id,1);
                case 'Workspace',               id = new_data(chart,'WORKSPACE'); sfdlg(id,1);
                case 'Temporary...',            id = new_data(chart,'TEMPORARY'); sfdlg(id,1);
                case 'Constant...',             id = new_data(chart,'CONSTANT'); sfdlg(id,1);
                case 'Parameter...',            id = new_data(chart,'PARAMETER'); sfdlg(id,1);
                case 'Data Store Memory...',    id = new_data(chart,'DATA_STORE_MEMORY'); sfdlg(id,1);
                case 'Target...',               id = new_target(machine); sfdlg(id,1);
                case 'Select All',              sf('SelectAll',chart);
                case {'Start', 'Start Real-Time Code'}, start_simulation(machine);
                case {'Stop', 'Stop Real-Time Code'},   stop_simulation(machine);
                case 'Pause',                   sfsim('pause',machine);
                case 'Continue',                sfsim('continue',machine);
                case 'Simulation',              sfsim('syncChart', chart);
                case 'Connect To Target',       sfsim('connect',machine);
                case 'Disconnect From Target',  sfsim('disconnect',machine);
                case 'Configuration Parameters...',
                    if(sf('get',machine,'machine.isLibrary'))
                        return;
                    end
                    modelH = sf('get', machine, '.simulinkModel');
                    set_param(modelH, 'SimulationCommand', 'SimParamDialog');
                case 'Open Simulation Target', goto_target(machine,'sfun');
                case 'Open RTW Target', goto_target(machine,'rtw');
                case 'Open MEX Target', goto_target(machine,'mex');
                case 'Open HDL Target', goto_target(machine,'hdl');

                case 'View',
                    ch = get(obj, 'child');

                    toolbarUp = sf('get', chart,'.toolbarVis');
                    if toolbarUp, set(ch(1), 'checked', 'on');
                    else set(ch(1), 'checked', 'off');
                    end;

                case 'Toolbar',
                    switch(get(obj, 'checked')),
                        case 'on',  sf('set', chart, '.toolbarVis',0);
                        case 'off',	sf('set', chart, '.toolbarVis',1);
                    end;

                case 'Edit',
                    ch = get(obj, 'child');
                    transOrderChild = findobj(ch,'Label','Show Transition Execution Order');
                    showTransOrder = ~sf('get', chart, '.dontShowTransitionExecutionOrder');
                    if showTransOrder, set(transOrderChild, 'checked', 'on');
                    else set(transOrderChild, 'checked', 'off');
                    end;
                case 'Show Transition Execution Order',
                    switch(get(obj, 'checked')),
                        case 'on',  sf('set', chart, '.dontShowTransitionExecutionOrder',1);
                        case 'off',	sf('set', chart, '.dontShowTransitionExecutionOrder',0);
                    end;

                case 'Tools',
                    ch = get(obj, 'child');
                    sm = Stateflow.SyntaxHighlighter;
                    if sm.Enabled
                        set(ch(1), 'checked', 'on');
                    else
                        set(ch(1), 'checked', 'off');
                    end

                case 'Syntax Coloring'
                    sm = Stateflow.SyntaxHighlighter;
                    sm.Enabled = ~sm.Enabled;

                otherwise,
                    if ~isempty(regexp(menuLabelStr,'^Open \S+ Target$', 'once'))
                        % handle custom targets added to menu at load time
                        name = sscanf(menuLabelStr,'Open %s');
                        goto_target(machine,name);
                    else
                        sizeValue = sscanf(menuLabelStr,'%d');
                        if ~isempty(sizeValue)
                            size_menu(chart,obj,sizeValue);
                            return;
                        end
                    end
            end
        case 'uitoggletool',
            set(obj, 'state', 'off');
            btnCmd = get(obj, 'Tag');
            switch(btnCmd),
                case 'Up',       sf('UpView', chart);
                case 'Back',     sf('BackView', chart);
                case 'Forward',  sf('ForwardView', chart);
                case 'New',   sfnew;
                case 'Open',  sfopen;
                case 'Save',  ui_save(machine, false);
                case 'Print', sfprint(chart, 'default', 'printer', 1, 0);
                case 'Cut',   sf('Cut', chart);
                case 'Copy',  sf('Copy', chart);
                case 'Paste', sf('Paste', chart);
                case 'Undo',  sf('Undo', chart);
                case 'Redo',  sf('Redo', chart);
                case 'Parse',
                    parse_this(chart);
                case 'Build',
                    try
                        autobuild_driver('build',machine,'sfun','yes');
                    catch
                    end
                case 'RebuildAll',
                    try
                        autobuild_driver('rebuildall',machine,'sfun','yes');
                    catch
                    end
                case 'Start',    start_simulation(machine);
                case 'Stop',     stop_simulation(machine);
                case 'PauseBtn', sfsim('pause',machine);
                case 'Explore',  view_in_explorer(chart);
                case 'Debug',    goto_debugger(chart);
                case 'Find',     sfsrch('create', chart);
                case 'Search  Replace',     sfsnr(chart);
                case 'Target',   goto_target(machine,'sfun');
                case 'Simulink', simulink;
            end;


        otherwise
            if nargin>0
                fprintf(1,'%s callback ''%s'' is TBD!',upper(get(obj,'Type')),command);
            else
                fprintf(1,'%s callback ''%s'' is TBD!',upper(get(obj,'Type')),command);
            end
    end

    set(0, 'ShowHiddenHandles', shh);
catch ME
    disp(ME.message);
    set(0, 'ShowHiddenHandles', shh);
end

%--------------------------------------------------------------------------
function start_simulation(machine)

modelH = sf('get', machine, '.simulinkModel');

switch get_param(modelH, 'simulationStatus')
    case {'stopped','terminating'}
        if strcmpi(get_param(modelH, 'RapidAcceleratorSimStatus'), 'inactive')
            % Make sure it's not during rapid accel mode building.
            sfsim('start', machine);
        end
    case 'external'
        extMode = get_param(modelH, 'ExtModeTargetSimStatus');
        if strcmp(extMode, 'waitingToStart')
            sfsim('start', machine);
        end
    otherwise
        sfsim('continue', machine);
end

%--------------------------------------------------------------------------
function size_menu( chart, obj, sizeValue )
%
%
%
parent = get(obj,'Parent');
menuLabelStr = get(parent,'Label');
menuLabelStr( find(menuLabelStr=='&') ) = [];
switch menuLabelStr
    case 'Set Font Size'
        selectedList = sf('SelectedObjectsIn',chart);        
        % API that supports undo/redo commands, g179665
        sf('MenuSetFontSize', sizeValue, selectedList);        
    case 'Junction Size'
        sf('set',sf('SelectedObjectsIn',chart),'junction.position.radius',sizeValue);
    case 'Arrowhead Size'
        sf('set',sf('SelectedObjectsIn',chart),'state.arrowSize',sizeValue);
        sf('set',sf('SelectedObjectsIn',chart),'junction.arrowSize',sizeValue);
    otherwise, error('Stateflow:UnexpectedError','Bad size menu.');
end
%--------------------------------------------------------------------------
%{
% NOT USED. KEEP IT FOR NOW.
function color_menu( chart, obj, rgb )
if strcmp(get(obj,'Checked'),'on')
return;
end
parent = get(obj,'Parent');
set(get(parent,'Child'),'Checked','off');
set(obj,'Checked','on');
menuLabelStr = get(parent,'Label');
menuLabelStr( find(menuLabelStr=='&') ) = [];
switch menuLabelStr
case 'State Color'
sf('set',chart,'.stateColor',rgb);
case 'State Label Color'
sf('set',chart,'.stateLabelColor',rgb);
case 'Transition Color'
sf('set',chart,'.transitionColor',rgb);
case 'Transition Label Color'
sf('set',chart,'.transitionLabelColor',rgb);
case 'Junction Color'
sf('set',chart,'.junctionColor',rgb);
case 'Selection Color'
sf('set',chart,'.selectionColor',rgb);
case 'Chart Color'
sf('set',chart,'.chartColor',rgb);
otherwise, error('Stateflow:UnexpectedError','Bad color menu.');
end
%}
%--------------------------------------------------------------------------
function vertical_slide( chart, obj )
%
%
%
fig = sf('get', chart, '.hg.figure');
viewLimits = sf('get', chart, '.viewLimits');
viewHeight = viewLimits(4) - viewLimits(3);
viewLimits(3) = -get(obj, 'Value');
viewLimits(4) = viewLimits(3) + viewHeight;

sf('set', chart, '.viewLimits', viewLimits);
figure(fig);	% to stop the scrollbars from stealing the focus.
%--------------------------------------------------------------------------
function horizontal_slide(chart, obj)
%
%
%
fig = sf('get', chart, '.hg.figure');
viewLimits = sf('get', chart, '.viewLimits');
viewWidth = viewLimits(2) - viewLimits(1);
viewLimits(1) = get(obj, 'Value');
viewLimits(2) = viewLimits(1) + viewWidth;

sf('set', chart, '.viewLimits', viewLimits);
figure(fig);	% to stop the scroll from stealing the focus.
%--------------------------------------------------------------------------
function zoom_size( chart, obj )
%
%
%
zoomIndex = get(obj,'Value');
zoomFactors = sf('get',chart,'.zmFactors');
sf('set',chart,'.zoomFactor',zoomFactors(zoomIndex));
set(obj, 'vis','off');
%--------------------------------------------------------------------------
function matlab_exit()
%
%
%
result = questdlg('Really close everything and exit MATLAB?','', 'Ok','Cancel','Cancel');
switch result,
    case 'Ok',

        sfclose('all');
        exit;
end;
%--------------------------------------------------------------------------
function goto_debugger(chart)
%
%
%
machine = actual_machine_referred_by(chart);
sfdebug('gui','init',machine);
%--------------------------------------------------------------------------
%{
% NOT USED. KEEP IT AS OF NOW.
function sfunId = get_sfun_target_l(id)
%
%
%
chartISA = sf('get','default','chart.isa');
machineISA = sf('get','default','machine.isa');

switch(sf('get', id, '.isa')),
case chartISA,
machineId = sf('get', id, '.machine');
case machineISA,
machineId = id;
otherwise
error('Stateflow:UnexpectedError','Bad id passed to get_sfun_target_l');
end;

targets = sf('find','all','target.machine',machineId);
sfunId = sf('find',targets,'target.name','sfun');
%}
%--------------------------------------------------------------------------
function id = view_in_explorer(chartId)
%
%
%
sfexplr;
selectionList = sf('SelectedObjectsIn',chartId);
switch length(selectionList)
    case 1,
        id = selectionList;
    otherwise,
        viewObjId= sf('get',chartId,'chart.viewObj');
        if ~isempty(viewObjId) && isequal(viewObjId,chartId)
            id = chartId;
        else
            id = viewObjId;
        end
end
sf('Explr','VIEW',id);

%--------------------------------------------------------------------------
function rcs_get_latest_version(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
try
    reload = verctrl('get', modelFile, 0);
    if (reload)
        reloadsys(modelFile);
    end
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_check_out(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
if (isunix),
    dirtyStr = get_param(modelHandle, 'dirty');
    cmdispatch('CHECKOUT', modelFile, dirtyStr);
else
    try
        reload = verctrl('checkout', modelFile, 0);
        if (reload)
            reloadsys(modelFile);
        end
    catch ME
        errordlg(ME.message, 'Error', 'modal');
    end
end

%--------------------------------------------------------------------------
function rcs_check_in(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
isDirty = strcmp( get_param(modelHandle, 'dirty'), 'on');
if (isDirty)
    sfsave(modelHandle);
    % did that work? sfsave does not return a status flag, so re-get the
    % dirty flag of the model:
    isDirty = strcmp( get_param(modelHandle, 'dirty'), 'on');
    if (isDirty),
        % save operation failed, somehow
        return
    end
end
% modelFile may have changed. re-get it
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return; % Cancel a save must have occurred.  Just return (successfully).
end
if (isunix)
    % Call cmdispatch with dirty flag set 'off'
    cmdispatch('CHECKIN', modelFile, 'off');
else
    try
        reload = verctrl('checkin', modelFile, 0);
        if (reload)
            reloadsys(modelFile);
        end
    catch ME
        errordlg(ME.message, 'Error', 'modal');
    end

end
%--------------------------------------------------------------------------
function rcs_undo_check_out(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
if (isunix)
    % Call cmdispatch
    dirtyStr = get_param(modelHandle, 'dirty');
    cmdispatch('UNDOCHECKOUT', modelFile, dirtyStr);
else
    try
        reload = verctrl('uncheckout', modelFile, 0);
        if (reload)
            reloadsys(modelFile);
        end
    catch ME
        errordlg(ME.message, 'Error', 'modal');
    end
end
%--------------------------------------------------------------------------
function rcs_add_to_source_control(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
isDirty     = strcmp( get_param(modelHandle, 'dirty'), 'on');
if (isDirty)
    sfsave(modelHandle);
end
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return; % Cancel a save must have occurred.  Just return (successfully).
end
try
    reload = verctrl('add', modelFile, 0);
    if (reload)
        reloadsys(modelFile);
    end
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_remove_from_source_control(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
try
    verctrl('remove', modelFile, 0);
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_history(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
try
    reload = verctrl('history', modelFile, 0);
    if (reload)
        reloadsys(modelFile);
    end
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_differences(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
isDirty     = strcmp( get_param(modelHandle, 'dirty'), 'on');
if (isDirty)
    sfsave(modelHandle);
end
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return; % Cancel a save must have occurred.  Just return (successfully).
end
try
    verctrl('showdiff', modelFile, 0);
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_properties(machine)
%
%
%
modelHandle = sf('get',machine,'machine.simulinkModel');
modelFile = get_param(modelHandle, 'FileName');
if(isempty(modelFile))
    return;
end
try
    reload = verctrl('properties', modelFile, 0);
    if (reload)
        reloadsys(modelFile);
    end
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function rcs_start_source_control_system
%
%
%
try
    verctrl('runscc', 0);
catch ME
    errordlg(ME.message, 'Error', 'modal');
end
%--------------------------------------------------------------------------
function obj = safe_gcbo_l
%
% Get the Callback Object independent of handle visibilities.
%
obj = menu_item_accelerator_helper('getmenu');
if isempty(obj)
    shh = get(0, 'ShowHiddenHandles');
    set(0,'ShowHiddenHandles', 'on');
    obj = gcbo;
    if (isempty(obj)),
        obj = gco;
        if isempty(obj), obj = gcf; end;
    end;
    set(0, 'ShowHiddenHandles', shh);
end
%--------------------------------------------------------------------------
function obj = safe_gcbf_l
%
% Get the Callback Figure independent of handle visibilities.
%
shh = get(0, 'ShowHiddenHandles');
set(0,'ShowHiddenHandles', 'on');
obj = gcbf;
set(0, 'ShowHiddenHandles', shh);
%--------------------------------------------------------------------------
function ui_save(machine, saveAs)
%
% Call sfsave but take into account any UI requirements
%
modelH = sf('get', machine, '.simulinkModel');

if strcmp(get_param(modelH, 'UpdateHistory'), 'UpdateHistoryWhenSave')
    slchangelog
end

if saveAs
    sfsave(machine, sf('get',machine,'.name'), 1);
else
    sfsave(machine, [], 1);
end

% [EOF]
