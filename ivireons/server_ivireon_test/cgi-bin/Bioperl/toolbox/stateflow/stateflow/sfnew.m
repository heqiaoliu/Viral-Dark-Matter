function varargout = sfnew(varargin)
%SFNEW Creates a new SIMULINK model and Stateflow diagram.
%   SFNEW('-CHARTTYPE', 'MACHINENAME') creates a new Simulink model with
%   the specified name, containing an empty Stateflow diagram (block) of
%   the specified type.
%
%      CHARTTYPE can be 'Classic', 'Mealy', 'Moore' or 'TT' (Truth Table).
%      If CHARTTYPE is not specified, the default diagram type is 'Classic'.
%
%      If MACHINENAME is not specified, use Simulink's default new model
%      name 'untitled'.
%        
%   See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFHELP.

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.19.2.12 $  $Date: 2009/06/16 06:00:16 $

if nargin > 2 || nargout > 2
    errmsg = ['Too many input or output arguments.' 10 ...
              'Usage: [model_handle, machine_id] = sfnew <-mealy/-moore/-tt> <model_name>'];
    error('Stateflow:Error',errmsg);
end

eventDispatcher = [];

try
    if ~sf('License', 'basic'),
        open_system('sf_examples');
        sf('Private', 'sf_demo_disclaimer');
        return;
    end;

    % keep Model Explorer from processing events during SL & SF load
    eventDispatcher = DAStudio.EventDispatcher;
    eventDispatcher.broadcastEvent('MESleepEvent');
    
    % Default values
    machineName = [];
    chartType = 'classic';

    for arg = varargin(:)'
        if ~ischar(arg{1})
            warning('Stateflow:UnexpectedError','Inputs to sfnew must be string!');
        else
            chartType = update_chart_type(chartType, arg{1});
            machineName = update_model_name(machineName, arg{1});
        end
    end

    % If a name was passed in, use it.
    if ~isempty(machineName)
        h = new_system(machineName);
    else
        h = new_system;
    end
    
    modelName = get_param(h,'name');
    newMachineH = sf('new', 'machine', '.name', modelName, '.simulinkModel', h);

    mustClose = 0;
    if(isempty(sf('find',sf('MachinesOf'),'machine.name','sflib')))
        mustClose = 1;
        sflib([],[],[],'load');
    end
    open_system(h);
    modelName = get_param(h,'Name');
    chartName = get_default_chart_name(chartType);
    
    sfBlk = [modelName, '/', chartName];
    add_block(['sflib/', chartName], sfBlk);

    chartId = sf('Private', 'block2chart', sfBlk);
    if strcmpi(chartType, 'mealy')
        sf('set', chartId, 'chart.stateMachineType', 'MEALY_MACHINE');
    elseif strcmpi(chartType, 'moore')
        sf('set', chartId, 'chart.stateMachineType', 'MOORE_MACHINE');
    end
        
    if nargout>0
        varargout{1} = h;
        if(nargout>1)
            varargout{2} = newMachineH;
        end
    end

    if(mustClose)
        bdclose('sflib');
    end
catch ME
    if ~isempty(eventDispatcher)
        eventDispatcher.broadcastEvent('MEWakeEvent');
    end
    rethrow(ME);
end

eventDispatcher.broadcastEvent('MEWakeEvent');
return;


function chartType = update_chart_type(chartType, arg)

if ~isempty(arg) && ischar(arg) && arg(1) == '-'
    arg = lower(arg(2:end));
    switch arg
        case {'mealy', 'moore', 'tt'}
            chartType = arg;
    end
end
return;            


function modelName = update_model_name(modelName, arg)

if ischar(arg) && ~isempty(regexp(arg, '^[a-zA-Z]\w*$', 'once' ))
    modelName = arg;
end
return;


function chartName = get_default_chart_name(chartType)

switch lower(chartType)
    case 'mealy'
        chartName = 'Chart';
    case 'moore'
        chartName = 'Chart';
    case 'tt'
        chartName = 'Truth Table';
    otherwise
        chartName = 'Chart';
end
return;
