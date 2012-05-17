function [outputs, info] = simulate(this, timespan, inputs, options)
% SIMULATE Simulates the model and returns its time response.
%
% [outputs, info] = simulate(this, timespan, inputs, options)
%

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/12/05 02:22:36 $

model = this.getName;

% Default arguments
if (nargin < 2 || isempty(timespan)), timespan = []; end
if (nargin < 3 || isempty(inputs)),   inputs   = []; end
if (nargin < 4 || isempty(options)),  options  = modelpack.simoptions(this); end

% Set model configuration, if necessary.
if ~isempty(options.Configuration)
  oldconfig = this.getCurrentConfig;
  this.setCurrentConfig(options.Configuration);
else
   oldconfig = [];
end

% Determine which outputs to log.
if isempty(options.Outputs)
   %No outputs specified, use all defined in the model
   IDs = this.getOutputs;
else
  IDs = options.Outputs;
  %Check IDs are all valid
  isValid = this.isValidPort(IDs);
  if ~all(isValid)
     ctrlMsgUtils.error('SLControllib:modelpack:slInvalidPort','options.Output')
  end
  %Check ports are outputs
  isValid = strcmp(IDs.getType,'Output');
  if ~all(isValid)
     strPorts = utGetPortNameList(this,IDs(~isValid));
     ctrlMsgUtils.error('SLControllib:modelpack:slAddOutputInvalidType',strPorts)
  end
end

% Experiment inputs
if isempty(inputs)
   %No inputs specified
   InData = cell(0,1);
else
   InData = timeseries2struct(this, inputs);
end

% Enable data logging at selected ports.
ports    = findSimulinkPorts(this, IDs);
settings = logSetup(this, ports);
% Create cleanup object to reset model changes
hCleanup = onCleanup(@() localCleanup(this,ports,settings,options,oldconfig));

%Check timespan for finite values and values > stopTime
stopTime = str2double( this.getCurrentConfig.Components(1).StopTime );
timespan(~isfinite(timespan) | timespan > stopTime) = stopTime;
timespan(~isfinite(timespan)) = max(timespan(isfinite(timespan))); %Ensure finite times
timespan = unique(timespan);

if ~isprop(this,'simWasStopped')
   %Create instance property to use in stopsim callback
   schema.prop(this,'simWasStopped','bool');
end

% Simulate the model.
%% SimOptions = simset( SimOptions, 'InitialState', this.getCurrentState );
% REM: Log written to local Model_DataLog variable.
this.simWasStopped = false;
L = handle.listener(options,'StopSim',@(hSrc,hData) localStopSim(this)); %#ok<NASGU>
sim(model, timespan, [], InData{:});

% Extract logged output signals
outputs = {};
for ct = 1:length(IDs)
  outputs{ct} = findLog(this, ports(ct), Model_DataLog); %#ok<AGROW>
end

% Simulation information
info = struct(...
   'userStopped',this.simWasStopped);
end

function localCleanup(this,ports,settings,options,oldconfig)
% Restore data logging settings
logCleanup(this, ports, settings);

% Restore model configuration, if necessary.
if ~isempty(options.Configuration)
   this.setCurrentConfig(oldconfig);
end
end

function localStopSim(this)
%% Manage stop sim events from options object
set_param(this.getName,'SimulationCommand','Stop')
this.simWasStopped = true;
end