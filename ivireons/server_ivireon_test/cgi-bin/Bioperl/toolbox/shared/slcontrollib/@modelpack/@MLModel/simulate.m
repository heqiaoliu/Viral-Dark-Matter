function [outputs, info] = simulate(this, timespan, inputs, options)
% SIMULATE Simulates the model and returns its time response.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:53:16 $

model = this.getName;

% Default arguments
if (nargin < 2 || isempty(timespan)), timespan = []; end
if (nargin < 3 || isempty(inputs)),   inputs   = []; end
if (nargin < 4 || isempty(options)),  options  = modelpack.simoptions(this); end

% Set model configuration, if necessary.
if ~isempty(options.Configuration)
  oldconfig = this.getCurrentConfig;
  this.setCurrentConfig(options.Configuration);
end

% Determine which outputs to log.
if ~isempty(options.Outputs)
  IDs = options.Outputs;
else
  IDs = this.getOutputs;
end

% Experiment inputs
InData = timeseries2struct(this, inputs);

% Simulate the model.
% REM: Log written to local Model_DataLog variable.
try
  %% SimOptions = simset( SimOptions, 'InitialState', this.getCurrentState );
  SimOptions = simget(model);
  msim(model, timespan, SimOptions, InData{:});
catch
  % Simulation failed
  Model_DataLog = [];
end

% Restore model configuration, if necessary.
if ~isempty(options.Configuration)
  this.setCurrentConfig(oldconfig);
end

% Extract logged output signals
outputs = {};
for ct = 1:length(IDs)
  outputs{ct} = findLog(this, ports(ct), Model_DataLog);
end

% Simulation information
info = [];
