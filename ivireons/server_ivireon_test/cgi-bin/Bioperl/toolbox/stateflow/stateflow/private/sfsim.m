function varargout = sfsim(varargin)
% SFSIM Implementaton of Stateflow-SIMULINK simulation management.

%	Jay R. Torgerson
%	E.Mehran Mestchian
%       Copyright 1995-2008 The MathWorks, Inc.
%  $Revision: 1.29.4.10 $  $Date: 2010/05/20 03:36:35 $

varargout = [];

% assert correct number of input args
method = varargin{1};

if nargin<2 || strcmp(method,'stopped') % EMM-- Must ignore the previously session specific SL 'StopFcn'
    model = bdroot(gcs);
    machineId = sf('find','all','machine.name',model);
    if length(machineId)~=1
        error('Stateflow:UnexpectedError','Failed to located Stateflow machine ''%s''.',model);
    end
else
    switch(method)
        case 'syncChart',
            chartId = varargin{2};
            machineId = sf('get', chartId, 'chart.machine');
            syncingChart = 1;
        otherwise,
            machineId = varargin{2};
            syncingChart = 0;
    end;
end

if(sf('get',machineId,'machine.isLibrary') && ~syncingChart)
    return;
end

switch(method),
    case 'start',    start_method(machineId);
    case 'connect',  connect_method(machineId);
    case 'disconnect', disconnect_method(machineId);
    case 'running',  running_method(machineId, false);
    case 'running_from_command_line',  running_method(machineId, true);
    case 'stop',     stop_method(machineId);
    case 'stopped',  stopped_method(machineId);
    case 'pause',    pause_method(machineId);
    case 'continue', continue_method(machineId);
    case 'params',   params_method(machineId);
    case 'syncChart', sync_chart_method(chartId);
    case 'syncCharts', sync_charts_method(machineId);
    case 'compile_fail', compile_fail_method(machineId);
    otherwise, warning('Stateflow:UnexpectedError',['Bad command passed to sfsim(): ',method]);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function start_method(machineId)
%
% Called from Stateflow Editor GUI
%
modelH = sf('get', machineId, '.simulinkModel');

warnStatus = warning('off', 'backtrace');
set_param(modelH,'SimulationCommand','Start');

warning(warnStatus);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function connect_method(machineId)
%
% Called from Stateflow Editor GUI
%
modelH = sf('get', machineId, '.simulinkModel');
set_param(modelH,'SimulationCommand','connect');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function disconnect_method(machineId)
%
% Called from Stateflow Editor GUI
%
modelH = sf('get', machineId, '.simulinkModel');
set_param(modelH,'SimulationCommand','disconnect');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function running_method(machineId, fromCmdLine)
%
% Called directly from SIMULINK by sfblk.initfcn_method
%
symWiz = sf('get', machineId, '.symbolWiz');
if ~isequal(symWiz, 0) && ishandle(symWiz),
    delete(symWiz);
end;

modelH = sf('get', machineId, 'machine.simulinkModel');
switch get_param(modelH, 'simulationMode')
    case {'rapid-accelerator', 'external'}
        extmode = true;
    otherwise
        extmode = false;
end

eml_man('update_ui_state',machineId,'run');
sf('set',machineId,'machine.iced',1);

charts = find_charts_related_to_machine(machineId);
for chart = charts(:).'
    if extmode
        chart_running_external_mode(chart, machineId, modelH);
    else
        chart_running(chart, machineId, fromCmdLine);
    end
end

sf('DebugTrap', 'prompt'); % if break into debugger, should give a prompt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stopped_method(machineId)
%
% Called directly from SIMULINK **mdl** StopFcn --will change when SIMULINK gives us a StopFcn for blocks.
%
%
% simlation menu to stop mode.
%
sf('set', machineId, 'machine.iced', 0);
eml_man('update_ui_state',machineId);
charts = find_charts_related_to_machine(machineId);
for chart = charts(:).'
    chart_stopped(chart,machineId);
    if(sf_debug_using_unified_editors)
        % Remove animations from relevant editors
        editors = sf_debug_collect_all_unified_editors_related_to(chart);
        for i = 1:length(editors)
            editor = editors(i);
            if(editor.isIndicatorInstalled('SFAnimation'))
                editor.uninstallIndicator('SFAnimation');
            end
        end
    else
        sf('Highlight', chart, []);
    end
end;

clear global sfDB;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stop_method(machineId)
%
%
%
modelH = sf('get', machineId, '.simulinkModel');

% For robustness, check whether or not the model is already stopped.
switch get_param(modelH, 'simulationStatus')
    case 'stopped'
        stopped_method(machineId);
    case 'terminating'
        stopped_method(machineId);
    otherwise
        set_param(modelH, 'SimulationCommand', 'Stop');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pause_method(machineId)
%
%
%
modelH = sf('get', machineId, '.simulinkModel');

if ~strcmp(get_param(modelH, 'SimulationStatus'),'running'), return; end;

charts = find_charts_related_to_machine(machineId);
for chart = charts(:).'
    chart_paused(chart, machineId);
end;
set_param(modelH, 'SimulationCommand','pause');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compile_fail_method(machineId)

eml_man('update_ui_state',machineId,'idle');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function continue_method(machineId)
%
%
%
modelH = sf('get', machineId, '.simulinkModel');

if ~strcmp(get_param(modelH, 'SimulationStatus'),'paused'), return; end;

charts = find_charts_related_to_machine(machineId);
for chart = charts(:).'
    chart_continuing(chart,machineId);
end;

set_param(modelH, 'SimulationCommand','continue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params_method(machineId)
%
%
%
simprm('create', sf('get',machineId,'.simulinkModel'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sync_charts_method(machineId)

charts = find_charts_related_to_machine(machineId);
for chart = charts(:).'
    sync_chart_method(chart);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sync_chart_method(chartId)
%
% Synchronize said chart's menus and iced mode as per it's
% activeInstance and the referred machine's simulation status.
%
machineId = actual_machine_referred_by(chartId);

eml_man('update_ui_state',machineId);

if(sf('get',machineId,'machine.isLibrary')),
    chart_simulation_menu(chartId, 'off');
    sync_chart_ice_mode(chartId,machineId);

    % if you're in a library and NOT viewing an instance, then
    % set your toolbarMode to LIBRARY_TOOLBAR, otherwise, set it to
    % FULL_TOOLBAR
    instanceView = sf('get', chartId, '.activeInstance');
    if isequal(instanceView, 0)
        sf('set', chartId, '.toolbarMode', 'LIBRARY_TOOLBAR');
    else
        sf('set', chartId, '.toolbarMode', 'FULL_TOOLBAR');
    end
else
    sf('set', chartId, '.toolbarMode', 'FULL_TOOLBAR');
    chart_simulation_menu(chartId, 'on');
    modelH = sf('get', machineId, 'machine.simulinkModel');
    switch get_param(modelH, 'simulationStatus')
        case 'stopped'
            chart_stopped(chartId,machineId);
        case 'terminating'
            chart_stopped(chartId,machineId);
        case 'running'
            chart_running(chartId,machineId, false);
        case 'external'
            chart_running_external_mode(chartId,machineId,modelH);
        case 'initializing'
            if sf('get',chartId,'chart.simulationMode') == 4 % EXTERNAL_CONNECTING
                chart_running_external_mode(chartId,machineId,modelH);
            end
        case 'running_from_command_line'
            chart_running(chartId,machineId, true);
        case 'paused'
            chart_paused(chartId,machineId);
        otherwise,
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sync_chart_ice_mode(chartId,actualMachineReferred)
%
% Update Chart's iced property

machineOfChart = sf('get',chartId,'chart.machine');
if(actualMachineReferred==machineOfChart)
    %%% this must be a real chart, not a link
    %%% in which case, chart's iced property must reflect the machine's
    machineOfChartIced = sf('get',machineOfChart,'machine.iced');
    chartIced = sf('get',chartId,'chart.iced');
    if(machineOfChartIced~=chartIced)
        sf('set',chartId,'chart.iced',machineOfChartIced);
    end

    if(is_eml_chart(chartId))
        eml_man('lock_editor',chartId,chartIced);
    end
else
    %%% this is a link chart. chart must always be iced when accessed
    %%% though a link. iceMode is irrelevant.

    chartIced = sf('get',chartId,'chart.iced');
    if(chartIced==0)
        sf('set',chartId,'chart.iced',1);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linksBeingViewed = find_links_being_viewed(machineId)
%
%
%
linksBeingViewed = [];

links = sf('get', machineId, '.sfLinks');
if ~isempty(links),
    instanceViews = sf('get', 'all', 'chart.activeInstance');
    linksBeingViewed = vset(links, '*', instanceViews);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function linkedCharts = find_linked_charts_related_to_machine(machineId)
%
%
%
linkedCharts = [];
linksBeingViewed = find_links_being_viewed(machineId);
for link = linksBeingViewed(:).';
    refBlock = get_param(link,'ReferenceBlock');
    instanceId = get_param(refBlock,'userData');
    chartId = sf('get', instanceId, '.chart');
    linkedCharts = [linkedCharts, chartId];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function charts = find_charts_related_to_machine(machineId)
%
%
%
charts = sf('get', machineId, '.charts');
charts = [charts, find_linked_charts_related_to_machine(machineId)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_stopped(chart,actualMachineReferred)
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

startH = findobj(fig, 'type', 'uimenu','label', '&Start');
if isempty(startH)
    startH = findobj(fig, 'type', 'uimenu','label', '&Continue');
end
set(startH, 'label', '&Start', 'enable', 'on', 'accelerator', 'T');

stopH = findobj(fig, 'type', 'uimenu', 'label', 'S&top');
set(stopH, 'enable', 'off','accelerator', '');

sync_chart_ice_mode(chart,actualMachineReferred);

sf('set', chart, '.simulationMode', 'STOPPED');

% look for all truthtables UI in this chart and dehighlight them
ttFcns = truth_tables_in(chart);
for i = 1:length(ttFcns)
    truth_table_man('dehighlight',ttFcns(i));
end

% YREN need similar routine to clear debugging status for eml editor
% NOT DONE YET

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_running(chart,actualMachineReferred, fromCmdLine)
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

startH = findobj(fig, 'type', 'uimenu','label', '&Start');
set(startH, 'enable', 'off', 'accelerator', '');

stopH = findobj(fig, 'type', 'uimenu', 'label', 'S&top');
set(stopH, 'enable', 'on','accelerator', 'T');

sync_chart_ice_mode(chart,actualMachineReferred);

if fromCmdLine
    sf('set', chart, '.simulationMode', 'RUNNING_FROM_COMMAND_LINE');
else
    sf('set', chart, '.simulationMode', 'RUNNING');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_running_external_mode(chart, actualMachineReferred, modelH)
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

sync_chart_ice_mode(chart,actualMachineReferred);

mode = get_param(modelH, 'ExtModeTargetSimStatus');
switch mode
    case 'notConnected'
        sf('set', chart, '.simulationMode', 'EXTERNAL_CONNECTING');
    case {'waitingToStart', 'paused'}
        if strcmpi(get_param(modelH, 'RapidAcceleratorSimStatus'), 'inactive')
            % Don't enable start button for 'rapid-accelerator' mode.
            % Rapid-accelerator mode sim shall start automatically.
            sf('set', chart, '.simulationMode', 'EXTERNAL_WAITING');
        end
    case {'running', 'startPending'}
        sf('set', chart, '.simulationMode', 'EXTERNAL_RUNNING');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_paused(chart,actualMachineReferred)
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

sync_chart_ice_mode(chart,actualMachineReferred);

sf('set', chart, '.simulationMode', 'PAUSED');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_continuing(chart, actualMachineReferred )
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

sync_chart_ice_mode(chart,actualMachineReferred);

sf('set', chart, '.simulationMode', 'RUNNING');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart_simulation_menu(chart, onOff)
%
%
%
fig = sf('get', chart, '.hg.figure');
if isequal(fig, 0)
    return;
end

simulationH = findobj(fig, 'type', 'uimenu', 'label', '&Simulation');
set(simulationH, 'enable', onOff);
