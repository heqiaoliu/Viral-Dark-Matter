function this = simoptions(model, config, states, outputs)
% SIMOPTIONS Constructor
%
% h = modelpack.simoptions(model)
%
% MODEL is a Model object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 21:01:40 $

% Create object
this = modelpack.simoptions;

% No argument constructor call
if nargin == 0
  return
end

% Check model argument
if ~isempty(model) && ~isa(model, 'modelpack.Model')
  ctrlMsgUtils.error( 'SLControllib:modelpack:errArgumentType', ...
                      'MODEL', 'modelpack.Model' );
end

% Default arguments
if (nargin < 2 || isempty(config)),  config  = []; end
if (nargin < 3 || isempty(states)),  states  = []; end
if (nargin < 4 || isempty(outputs)), outputs = []; end

% Set invariant properties
this.Version    = 1.0;

% Set public properties
this.Configuration = config;
this.InitialState  = states;
this.Outputs       = outputs;
