function varargout = traceabilityManager(methodName, varargin)
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2007/09/01 05:44:56 

varargout{1} = [];

% dispatch method
try
    switch(methodName)
        case {'showRTWMenu', ...
                'rtwHighlightCodeMenuItemEnabled', ...
                'getTraceableObjects'}
            varargout{1} = feval(methodName, varargin{1});
        case {'showHDLMenu', ...
                'hdlHighlightCodeMenuItemEnabled', ...
                'getTraceableObjects'}
            varargout{1} = feval(methodName, varargin{1});
        case {'getRTWMenuStatus', ...
                'makeSSId', ...
                'parseSSId'}
            varargout = feval(methodName, varargin{:});
        case {'getHDLMenuStatus', ...
                'makeSSId', ...
                'parseSSId'}
            varargout = feval(methodName, varargin{:});
        case {'rtwTraceObject', ...
                'unHighlightObject'}
            feval(methodName, varargin{:});
        case {'hdlTraceObject', ...
                'unHighlightObject'}
            feval(methodName, varargin{:});
        otherwise
            fprintf(1,'Unknown methodName %s passed to traceabilityManager', methodName);
    end
catch ME
    str = sprintf('Error calling traceabilityManager(%s): %s', methodName, ME.message);
    disp(str);
    if rtwprivate('rtwinbat')
        rethrow(ME);
    end
end


% display the RTW menu or not
function showIt = showRTWMenu(objectId)

showIt = false;
    
try
    % get modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');
    
    % call rtw function to get the display status for rtw menu
    showIt = rtwprivate('rtwreport', 'showHighlightCodeMenu', modelName);
catch ME
end

% display the HDL menu or not
function showIt = showHDLMenu(objectId)

showIt = false;

try
    % get modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');

    if(hdlcoderui.isslhdlcinstalled)
        showIt = true;
    end

catch ME
end


% enable the highlight code menu item or not
function enabled = rtwHighlightCodeMenuItemEnabled(objectId)

enabled = false;

try
    % get the modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');
    
    % call rtw to get the status of the highlight code menu item
    enabled = rtwprivate('rtwreport','enableHighlightCodeMenu', modelName);
catch ME
end

% check whether to enable the highlight code menu item or not
function enabled = hdlHighlightCodeMenuItemEnabled(objectId)

enabled = false;

try
    % get the modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');
    
    enabled = rtwprivate('rtwreport','enableHighlightHDLCodeMenu', modelName);
catch ME
end


function result = getRTWMenuStatus(objectId)

showIt = false;
enabled = false;

try
    % get the modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');

    % call rtw function to get the display status for rtw menu
    showIt = rtwprivate('rtwreport', 'showHighlightCodeMenu', modelName);

    % call rtw to get the status of the highlight code menu item
    enabled = rtwprivate('rtwreport','enableHighlightCodeMenu', modelName);
catch ME
end

result{1} = [showIt enabled];

% For now, always on for HDL menu
function result = getHDLMenuStatus(objectId)

showIt = false;
enabled = false;

try
    % get the modelName from the objectId
    machineId = actual_machine_referred_by(getChartOf(objectId));
    modelName = sf('get', machineId, 'machine.name');
    
    enabled = rtwprivate('rtwreport','enableHighlightHDLCodeMenu', modelName);

    if(hdlcoderui.isslhdlcinstalled)
        showIt = true;
    end
    
catch ME
end

result{1} = [showIt enabled];

% make SSId from parts
function result = makeSSId(blockPath, objectSSIdNumber, auxInfo)

objectSSId = [blockPath ':' objectSSIdNumber];

if ~isempty(auxInfo)
    objectSSId = [objectSSId ':' auxInfo];
end

result{1} = objectSSId;


% parse SSId
function result = parseSSId(objectSSId)

result = cell(3, 1);

ssIdFields = regexp(objectSSId, '^(.*?):(\d+)(:?[^:]+)?$', 'tokens', 'once');

if isempty(ssIdFields)
    return;
end

blockPath = ssIdFields{1};
ssIdNumber = ssIdFields{2};
auxInfo = ssIdFields{3};

if ~isempty(auxInfo) && auxInfo(1)==':'
    auxInfo(1) = []; % Trim off the leading ':'
end

result{1} = blockPath;
result{2} = ssIdNumber;
result{3} = auxInfo;

function rtwTraceObject(objectSSId)
rtwTraceObjectHelper(objectSSId,'rtw');

function hdlTraceObject(objectSSId)
rtwTraceObjectHelper(objectSSId,'hdl');

function rtwTraceObjectHelper(objectSSId,target)

% skip to the first outbound transition if this is a junction object
handle = ssIdToHandle(objectSSId);
if isempty(handle)
    return;
end
objectId = handle.Id;
JUNCTION_ISA = sf('get', 'default', 'junction.isa' );
objISA = sf('get', objectId, '.isa');
if objISA == JUNCTION_ISA
    srcTransitions = sf('get', objectId, '.srcTransitions');
    if ~isempty(srcTransitions)
        objectId = sf('find', srcTransitions, '.executionOrder', 1);
        root = sfroot;
        handle = root.idToHandle(objectId);
        objectSSId = handleTossId(handle);
    end
end

% navigate to the rtw generated source code
rtwtrace(objectSSId,target);


function result = getTraceableObjects(blockPath)

chartId = block2chart(blockPath);

% get SSID numbers of states
stateList = sf('find',sf('get', chartId, 'chart.states'),'~state.type','GROUP_STATE');
stateList = sf('get',stateList,'.ssIdNumber');
if is_eml_based_chart(chartId)
    result = stateList;
    return;
end

% exclude auto-generated empty transitions
transList = sf('get', chartId, 'chart.transitions');
rt = sfroot;
for i=length(transList):-1:1
   transObject = rt.idToHandle(transList(i));
   if(transList(i) ~= transObject.Id)
       % this is a non-representative sub/super transition
       % we need to remove it from the list
       transList(i) = [];
   end
end

idx = arrayfun(@(x) sf('get',x,'.autogen.isAutoCreated') && ...
         strcmp(sf('get',x,'.labelString'),'?'), transList);

transList = sf('get',transList(~idx),'.ssIdNumber');

% events
eventList = sf('find',sf('EventsIn',chartId),'~event.scope','INPUT_EVENT');
eventList = sf('get', eventList,'.ssIdNumber');

result = [stateList; transList; eventList];


function unHighlightObject(objectSSId)

handle = ssIdToHandle(objectSSId);

if isempty(handle)
    return;
end

objectId = handle.Id;

% for eml based charts we go to the function type state
if is_eml_based_chart(objectId)
    stateIds = sf('get', objectId, '.states');
    if length(stateIds) ~= 1
        return;
    end
    objectId = stateIds(1);
end

% for truth table autogenerated transitions we set the objectId to
% the source truth table objectId to be cleared below
TRANSITION_ISA = sf('get', 'default', 'transition.isa');
objectISA = sf('get', objectId, '.isa');
if objectISA == TRANSITION_ISA
    sourceObjectId = sf('get', objectId, 'transition.autogen.source');
    if sourceObjectId ~= 0
        objectId = sourceObjectId;
    end
end

if is_truth_table_fcn(objectId) || is_eml_truth_table_fcn(objectId)
    truth_table_function_man('dehighlight', objectId);
end

if is_eml_fcn(objectId)
    emlEditor = eml_man('get_editor_for_opened_object', objectId);
    if ~isempty(emlEditor)
        emlEditor.clearHighlight(objectId);
    end
end

% else by default we unhighlight everything inside the chart
chartId = getChartOf(objectId);
if chartId ~= 0
    sf('Highlight', chartId, []);
end

function flag = isHDLTraceabilityEnabled
    hdriver = get_param(bdroot,'HDLCoder');
    hCLI = hdriver.CoderParameterObject.CLI;
    flag = strcmp(hCLI.Traceability, 'on');
