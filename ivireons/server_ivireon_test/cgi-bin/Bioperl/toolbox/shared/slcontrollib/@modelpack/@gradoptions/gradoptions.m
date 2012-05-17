function this = gradoptions(model, config, states, outputs, type, perturb)
% GRADOPTIONS Constructor
%
% h = modelpack.gradoptions(model)
%
% MODEL is a Model object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 21:01:36 $

% Create object
this = modelpack.gradoptions;

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
if (nargin < 5 || isempty(type)),    type    = 'basic'; end
if (nargin < 6 || isempty(perturb)), perturb = [1e-8 1e-1]; end

% Set invariant properties
this.Version = 1.0;

% Set public properties
this.Configuration = config;
this.GradientType  = type;
this.InitialState  = states;
this.Outputs       = outputs;
this.Perturbation  = perturb;
